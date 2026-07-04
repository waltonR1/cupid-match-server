package com.ruoyi.cupid.service.impl;

import org.springframework.dao.TransientDataAccessException;
import org.springframework.dao.RecoverableDataAccessException;
import org.springframework.jdbc.CannotGetJdbcConnectionException;

/**
 * 消息重试只处理瞬时基础设施异常，业务校验失败必须由运营人员修正。
 */
public final class CupidMessageRetryPolicy
{
    private CupidMessageRetryPolicy()
    {
    }

    public static boolean isRetryable(Throwable error)
    {
        Throwable current = error;
        while (current != null)
        {
            if (current instanceof TransientDataAccessException
                    || current instanceof RecoverableDataAccessException
                    || current instanceof CannotGetJdbcConnectionException)
            {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }
}
