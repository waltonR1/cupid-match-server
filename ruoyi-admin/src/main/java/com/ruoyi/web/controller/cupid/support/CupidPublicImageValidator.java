package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.utils.file.FileUploadUtils;

final class CupidPublicImageValidator
{
    private static final String[] IMAGE_EXTENSIONS = { "jpg", "jpeg", "png", "webp" };

    private CupidPublicImageValidator()
    {
    }

    static String validate(MultipartFile file) throws IOException
    {
        if (file == null || file.isEmpty())
        {
            throw new IllegalArgumentException("empty_file");
        }
        try
        {
            FileUploadUtils.assertAllowed(file, IMAGE_EXTENSIONS);
        }
        catch (Exception e)
        {
            if (e instanceof IOException ioException)
            {
                throw ioException;
            }
            throw new IllegalArgumentException(e.getMessage(), e);
        }

        String extension = FileUploadUtils.getExtension(file).toLowerCase(Locale.ROOT);
        byte[] header = new byte[12];
        int read;
        try (InputStream input = file.getInputStream())
        {
            read = input.read(header);
        }
        if (("jpg".equals(extension) || "jpeg".equals(extension))
                && read >= 3
                && (header[0] & 0xff) == 0xff
                && (header[1] & 0xff) == 0xd8
                && (header[2] & 0xff) == 0xff)
        {
            return "image/jpeg";
        }
        if ("png".equals(extension)
                && startsWith(header, read, new byte[] {(byte) 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a}))
        {
            return "image/png";
        }
        if ("webp".equals(extension)
                && read >= 12
                && header[0] == 'R' && header[1] == 'I' && header[2] == 'F' && header[3] == 'F'
                && header[8] == 'W' && header[9] == 'E' && header[10] == 'B' && header[11] == 'P')
        {
            return "image/webp";
        }
        throw new IllegalArgumentException("invalid_file_content");
    }

    private static boolean startsWith(byte[] header, int read, byte[] expected)
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
}
