package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.io.InputStream;

public record CupidStoredObject(InputStream inputStream, String contentType, long contentLength) implements AutoCloseable
{
    @Override
    public void close() throws IOException
    {
        inputStream.close();
    }
}
