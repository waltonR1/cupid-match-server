package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.Locale;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.utils.uuid.IdUtils;

/**
 * Cupid Match 认证材料私有文件存储
 */
@Component
public class CupidVerificationMaterialStorage
{
    public static final String PRIVATE_PREFIX = "private://verification/";

    private static final String[] ALLOWED_EXTENSIONS = { "pdf", "jpg", "jpeg", "png", "webp" };

    private static final long MAX_SIZE = 10L * 1024L * 1024L;

    private static final String S3_PREFIX = "private/verification/";

    private final CupidStorageProperties storageProperties;

    private final ObjectProvider<CupidS3ObjectClient> s3ClientProvider;

    public CupidVerificationMaterialStorage(CupidStorageProperties storageProperties,
            ObjectProvider<CupidS3ObjectClient> s3ClientProvider)
    {
        this.storageProperties = storageProperties;
        this.s3ClientProvider = s3ClientProvider;
    }

    public StoredMaterial upload(String profileId, MultipartFile file) throws IOException
    {
        if (file == null || file.isEmpty())
        {
            throw new IllegalArgumentException("empty_file");
        }
        if (file.getSize() > MAX_SIZE)
        {
            throw new IllegalArgumentException("file_too_large");
        }
        String extension = extensionOf(file.getOriginalFilename());
        if (!isAllowed(extension))
        {
            throw new IllegalArgumentException("invalid_file_type");
        }
        String scanMessage = scanContent(extension, file);

        LocalDate today = LocalDate.now();
        String relativePath = profileId + "/" + today.getYear() + "/"
                + String.format("%02d", today.getMonthValue()) + "/"
                + String.format("%02d", today.getDayOfMonth()) + "/"
                + IdUtils.fastSimpleUUID() + "." + extension;
        if (isS3())
        {
            requireS3Client().put(storageProperties.getS3().getPrivateBucket(), S3_PREFIX + relativePath, file);
        }
        else
        {
            Path target = resolveRelative(relativePath);
            if (!target.startsWith(baseDir()))
            {
                throw new IllegalArgumentException("invalid_file_path");
            }
            Files.createDirectories(target.getParent());
            file.transferTo(target);
        }
        return new StoredMaterial(PRIVATE_PREFIX + relativePath.replace('\\', '/'),
                file.getOriginalFilename(), file.getContentType(), file.getSize(),
                "passed", scanMessage);
    }

    public MaterialFile resolve(String materialUrl) throws IOException
    {
        if (materialUrl == null || !materialUrl.startsWith(PRIVATE_PREFIX))
        {
            throw new IllegalArgumentException("invalid_material_url");
        }
        String relativePath = materialUrl.substring(PRIVATE_PREFIX.length());
        CupidStoragePaths.requireObjectKey(relativePath);
        if (isS3())
        {
            try
            {
                CupidStoredObject object = requireS3Client().open(
                        storageProperties.getS3().getPrivateBucket(), S3_PREFIX + relativePath);
                return new MaterialFile(object, filenameOf(relativePath));
            }
            catch (java.io.FileNotFoundException e)
            {
                throw new IllegalArgumentException("material_file_not_found", e);
            }
        }
        Path file = resolveRelative(relativePath);
        if (!file.startsWith(baseDir()) || !Files.isRegularFile(file))
        {
            throw new IllegalArgumentException("material_file_not_found");
        }
        return new MaterialFile(new CupidStoredObject(Files.newInputStream(file), contentType(file), Files.size(file)),
                file.getFileName().toString());
    }

    private boolean isS3()
    {
        return "s3".equalsIgnoreCase(storageProperties.getType());
    }

    private CupidS3ObjectClient requireS3Client()
    {
        CupidS3ObjectClient client = s3ClientProvider.getIfAvailable();
        if (client == null)
        {
            throw new IllegalStateException("S3 storage client is not available");
        }
        return client;
    }

    private String filenameOf(String relativePath)
    {
        int slash = relativePath.lastIndexOf('/');
        return slash >= 0 ? relativePath.substring(slash + 1) : relativePath;
    }

    private Path resolveRelative(String relativePath)
    {
        return baseDir().resolve(relativePath).normalize();
    }

    private Path baseDir()
    {
        Path profile = Paths.get(RuoYiConfig.getProfile()).toAbsolutePath().normalize();
        Path parent = profile.getParent();
        if (parent == null)
        {
            parent = profile;
        }
        return parent.resolve("cupid-private").resolve("verification").normalize();
    }

    private String extensionOf(String filename)
    {
        if (filename == null)
        {
            return "";
        }
        int dot = filename.lastIndexOf('.');
        return dot >= 0 ? filename.substring(dot + 1).toLowerCase(Locale.ROOT) : "";
    }

    private boolean isAllowed(String extension)
    {
        for (String allowed : ALLOWED_EXTENSIONS)
        {
            if (allowed.equals(extension))
            {
                return true;
            }
        }
        return false;
    }

    private String scanContent(String extension, MultipartFile file) throws IOException
    {
        byte[] header = new byte[16];
        int read;
        try (InputStream input = file.getInputStream())
        {
            read = input.read(header);
        }
        if (read < 0)
        {
            throw new IllegalArgumentException("empty_file");
        }
        if ("pdf".equals(extension) && startsWith(header, read, "%PDF-".getBytes(StandardCharsets.US_ASCII)))
        {
            return "pdf_signature_checked";
        }
        if (("jpg".equals(extension) || "jpeg".equals(extension))
                && read >= 3
                && (header[0] & 0xff) == 0xff
                && (header[1] & 0xff) == 0xd8
                && (header[2] & 0xff) == 0xff)
        {
            return "jpeg_signature_checked";
        }
        if ("png".equals(extension)
                && startsWith(header, read, new byte[] {(byte) 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a}))
        {
            return "png_signature_checked";
        }
        if ("webp".equals(extension)
                && read >= 12
                && header[0] == 'R' && header[1] == 'I' && header[2] == 'F' && header[3] == 'F'
                && header[8] == 'W' && header[9] == 'E' && header[10] == 'B' && header[11] == 'P')
        {
            return "webp_signature_checked";
        }
        throw new IllegalArgumentException("invalid_file_content");
    }

    private boolean startsWith(byte[] header, int read, byte[] expected)
    {
        if (read < expected.length)
        {
            return false;
        }
        for (int i = 0; i < expected.length; i++)
        {
            if (header[i] != expected[i])
            {
                return false;
            }
        }
        return true;
    }

    private String contentType(Path file)
    {
        try
        {
            String detected = Files.probeContentType(file);
            if (detected != null)
            {
                return detected;
            }
        }
        catch (IOException ignored)
        {
        }
        String name = file.getFileName().toString().toLowerCase(Locale.ROOT);
        if (name.endsWith(".pdf"))
        {
            return "application/pdf";
        }
        if (name.endsWith(".png"))
        {
            return "image/png";
        }
        if (name.endsWith(".webp"))
        {
            return "image/webp";
        }
        return "image/jpeg";
    }

    public record StoredMaterial(String materialUrl, String originalFilename, String contentType, long size,
            String scanStatus, String scanMessage)
    {
    }

    public record MaterialFile(CupidStoredObject object, String filename) implements AutoCloseable
    {
        public String contentType()
        {
            return object.contentType();
        }

        public long contentLength()
        {
            return object.contentLength();
        }

        public InputStream inputStream()
        {
            return object.inputStream();
        }

        @Override
        public void close() throws IOException
        {
            object.close();
        }
    }
}
