package com.ruoyi.common.exception.cupid;

import java.io.Serial;

/**
 * Cupid Match 前台接口业务异常
 */
public class CupidApiException extends RuntimeException
{
    @Serial
    private static final long serialVersionUID = 1L;

    private final int code;
    private final String error;

    public CupidApiException(int code, String error)
    {
        super(error);
        this.code = code;
        this.error = error;
    }

    public int getCode()
    {
        return code;
    }

    public String getError()
    {
        return error;
    }
}
