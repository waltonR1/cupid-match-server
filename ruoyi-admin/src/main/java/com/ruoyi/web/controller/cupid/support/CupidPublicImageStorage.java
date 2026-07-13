package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.net.URI;
import java.util.Optional;
import org.springframework.web.multipart.MultipartFile;

/**
 * Storage boundary for public profile images.
 */
public interface CupidPublicImageStorage
{
    String upload(MultipartFile file) throws IOException;

    Optional<URI> publicUri(String objectKey);

    CupidStoredObject open(String objectKey) throws IOException;

    void delete(String objectKey) throws IOException;
}
