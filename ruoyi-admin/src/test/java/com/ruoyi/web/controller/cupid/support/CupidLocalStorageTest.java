package com.ruoyi.web.controller.cupid.support;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.mock.web.MockMultipartFile;
import com.ruoyi.common.config.RuoYiConfig;

class CupidLocalStorageTest
{
    @TempDir
    Path tempDir;

    @Test
    void publicImageKeepsStableUrlAndCanBeRead() throws Exception
    {
        CupidStorageProperties properties = new CupidStorageProperties();
        properties.setLocalRoot(tempDir.toString());
        LocalCupidPublicImageStorage storage = new LocalCupidPublicImageStorage(properties);
        byte[] content = new byte[] {(byte) 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 1, 2, 3};

        String url = storage.upload(new MockMultipartFile("file", "photo.png", "image/png", content));

        assertTrue(url.matches("/profile/upload/\\d{4}/\\d{2}/\\d{2}/[a-f0-9]+\\.png"));
        assertFalse(storage.publicUri(url.substring("/profile/".length())).isPresent());
        try (CupidStoredObject object = storage.open(url.substring("/profile/".length())))
        {
            assertArrayEquals(content, object.inputStream().readAllBytes());
            assertEquals(content.length, object.contentLength());
        }
        storage.delete(url.substring("/profile/".length()));
        assertFalse(Files.exists(tempDir.resolve(url.substring("/profile/".length()))));
    }

    @Test
    void publicImageRejectsSpoofedContentAndUnexpectedKeys()
    {
        CupidStorageProperties properties = new CupidStorageProperties();
        properties.setLocalRoot(tempDir.toString());
        LocalCupidPublicImageStorage storage = new LocalCupidPublicImageStorage(properties);

        assertThrows(IllegalArgumentException.class, () -> storage.upload(
                new MockMultipartFile("file", "photo.jpg", "text/html", "<script>".getBytes(StandardCharsets.UTF_8))));
        assertThrows(IllegalArgumentException.class, () -> storage.open("upload/anything.jpg"));
    }

    @Test
    void privateMaterialKeepsPrivateReferenceAndLegacyLocalDirectory() throws Exception
    {
        Path profileRoot = tempDir.resolve("profile");
        new RuoYiConfig().setProfile(profileRoot.toString());
        CupidStorageProperties properties = new CupidStorageProperties();
        properties.setType("local");
        ObjectProvider<CupidS3ObjectClient> provider = new ObjectProvider<>() { };
        CupidVerificationMaterialStorage storage = new CupidVerificationMaterialStorage(properties, provider);
        byte[] content = "%PDF-1.7 test".getBytes(StandardCharsets.US_ASCII);

        CupidVerificationMaterialStorage.StoredMaterial stored = storage.upload("profile-1",
                new MockMultipartFile("file", "identity.pdf", "application/pdf", content));

        assertTrue(stored.materialUrl().matches(
                "private://verification/profile-1/\\d{4}/\\d{2}/\\d{2}/[a-f0-9]+\\.pdf"));
        String relativePath = stored.materialUrl().substring(CupidVerificationMaterialStorage.PRIVATE_PREFIX.length());
        assertTrue(Files.isRegularFile(tempDir.resolve("cupid-private/verification").resolve(relativePath)));
        try (CupidVerificationMaterialStorage.MaterialFile file = storage.resolve(stored.materialUrl()))
        {
            assertEquals("application/pdf", file.contentType());
            assertArrayEquals(content, file.inputStream().readAllBytes());
        }
    }
}
