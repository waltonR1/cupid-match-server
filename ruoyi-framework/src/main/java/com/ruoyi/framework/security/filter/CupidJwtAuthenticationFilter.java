package com.ruoyi.framework.security.filter;

import java.io.IOException;
import java.util.Collections;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.framework.web.service.CupidTokenService;

/**
 * Cupid Match 前台用户JWT认证过滤器
 */
@Component
public class CupidJwtAuthenticationFilter extends OncePerRequestFilter
{
    @Autowired
    private CupidTokenService tokenService;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request)
    {
        return !getPath(request).startsWith("/api/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException
    {
        CupidLoginUser principal = tokenService.getUserPrincipal(request);
        if (StringUtils.isNotNull(principal) && StringUtils.isNull(SecurityUtils.getAuthentication()))
        {
            tokenService.verifyToken(principal);
            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                    principal, null, Collections.emptyList());
            authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authenticationToken);
        }
        chain.doFilter(request, response);
    }

    private String getPath(HttpServletRequest request)
    {
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        return StringUtils.isNotEmpty(contextPath) ? requestUri.substring(contextPath.length()) : requestUri;
    }
}
