package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.net.URI;
import java.util.Optional;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.utils.file.FileUploadUtils;

@Component
@ConditionalOnProperty(prefix = "cupid.storage", name = "type", havingValue = "s3")
public class S3CupidPublicImageStorage implements CupidPublicImageStorage
{
    private final CupidStorageProperties properties;

    private final CupidS3ObjectClient client;

    public S3CupidPublicImageStorage(CupidStorageProperties properties, CupidS3ObjectClient client)
    {
        this.properties = properties;
        this.client = client;
    }

    @Override
    public String upload(MultipartFile file) throws IOException
    {
        String contentType = CupidPublicImageValidator.validate(file);
        String objectKey = "upload/" + FileUploadUtils.uuidFilename(file);
        client.put(properties.getS3().getBucket(), objectKey, file, contentType);
        return CupidStoragePaths.publicPath(objectKey);
    }

    @Override
    public Optional<URI> publicUri(String objectKey)
    {
        return CupidStoragePaths.publicUri(properties.getPublicBaseUrl(), objectKey);
    }

    @Override
    public CupidStoredObject open(String objectKey) throws IOException
    {
        return client.open(properties.getS3().getBucket(), CupidStoragePaths.requirePublicImageKey(objectKey));
    }

    @Override
    public void delete(String objectKey)
    {
        client.delete(properties.getS3().getBucket(), CupidStoragePaths.requirePublicImageKey(objectKey));
    }

}
