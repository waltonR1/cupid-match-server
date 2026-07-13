package com.ruoyi.web.controller.cupid.app;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.util.Optional;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.web.controller.cupid.support.CupidPublicImageStorage;
import com.ruoyi.web.controller.cupid.support.CupidStoredObject;

/**
 * Stable public image endpoint backed by local or S3-compatible storage.
 */
@RestController
public class CupidPublicImageController
{
    private static final Logger log = LoggerFactory.getLogger(CupidPublicImageController.class);

    private final CupidPublicImageStorage storage;

    public CupidPublicImageController(CupidPublicImageStorage storage)
    {
        this.storage = storage;
    }

    @GetMapping(Constants.RESOURCE_PREFIX + "/upload/**")
    public void read(HttpServletRequest request, HttpServletResponse response) throws IOException
    {
        String requestPath = request.getRequestURI().substring(request.getContextPath().length());
        String objectKey = requestPath.substring((Constants.RESOURCE_PREFIX + "/").length());
        try
        {
            Optional<URI> publicUri = storage.publicUri(objectKey);
            if (publicUri.isPresent())
            {
                response.setStatus(HttpServletResponse.SC_FOUND);
                response.setHeader("Location", publicUri.get().toASCIIString());
                response.setHeader("Cache-Control", "public, max-age=300");
                return;
            }
            try (CupidStoredObject object = storage.open(objectKey))
            {
                response.setContentType(object.contentType());
                if (object.contentLength() >= 0)
                {
                    response.setContentLengthLong(object.contentLength());
                }
                response.setHeader("Cache-Control", "public, max-age=31536000, immutable");
                object.inputStream().transferTo(response.getOutputStream());
            }
        }
        catch (FileNotFoundException e)
        {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
        catch (IllegalArgumentException e)
        {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
        catch (Exception e)
        {
            log.error("Failed to read public image {}", objectKey, e);
            response.sendError(HttpServletResponse.SC_BAD_GATEWAY);
        }
    }
}
