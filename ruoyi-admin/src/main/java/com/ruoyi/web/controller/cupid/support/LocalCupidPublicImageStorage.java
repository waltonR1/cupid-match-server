package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.utils.file.FileUploadUtils;

@Component
@ConditionalOnProperty(prefix = "cupid.storage", name = "type", havingValue = "local", matchIfMissing = true)
public class LocalCupidPublicImageStorage implements CupidPublicImageStorage
{
    private final CupidStorageProperties properties;

    public LocalCupidPublicImageStorage(CupidStorageProperties properties)
    {
        this.properties = properties;
    }

    @Override
    public String upload(MultipartFile file) throws IOException
    {
        CupidPublicImageValidator.validate(file);
        String objectKey = "upload/" + FileUploadUtils.uuidFilename(file);
        Path target = resolve(objectKey);
        Files.createDirectories(target.getParent());
        file.transferTo(target);
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
        Path file = resolve(CupidStoragePaths.requirePublicImageKey(objectKey));
        if (!Files.isRegularFile(file))
        {
            throw new java.io.FileNotFoundException(objectKey);
        }
        String contentType = Files.probeContentType(file);
        return new CupidStoredObject(Files.newInputStream(file),
                contentType == null ? "application/octet-stream" : contentType, Files.size(file));
    }

    @Override
    public void delete(String objectKey) throws IOException
    {
        Files.deleteIfExists(resolve(CupidStoragePaths.requirePublicImageKey(objectKey)));
    }

    private Path resolve(String objectKey)
    {
        String key = CupidStoragePaths.requireObjectKey(objectKey);
        Path root = Path.of(properties.getLocalRoot()).toAbsolutePath().normalize();
        Path target = root.resolve(key).normalize();
        if (!target.startsWith(root))
        {
            throw new IllegalArgumentException("invalid_file_path");
        }
        return target;
    }

}
