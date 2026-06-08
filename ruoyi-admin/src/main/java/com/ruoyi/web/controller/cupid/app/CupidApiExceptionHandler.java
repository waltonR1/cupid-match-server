package com.ruoyi.web.controller.cupid.app;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.exception.cupid.CupidApiException;

/**
 * Cupid Match 前台接口异常处理器
 */
@RestControllerAdvice(basePackages = "com.ruoyi.web.controller.cupid.app")
public class CupidApiExceptionHandler
{
    /**
     * 将业务异常转换为统一API响应
     */
    @ExceptionHandler(CupidApiException.class)
    public ResponseEntity<AjaxResult> handleCupidApiException(CupidApiException exception)
    {
        return ResponseEntity.status(exception.getCode())
                .body(AjaxResult.error(exception.getCode(), exception.getError()));
    }
}
