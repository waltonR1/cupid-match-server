package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidInboxMapper;
import com.ruoyi.cupid.service.ICupidInboxService;

/**
 * Cupid Match 收件箱服务实现。
 */
@Service
public class CupidInboxServiceImpl implements ICupidInboxService
{
    private static final int DEFAULT_LIMIT = 20;
    private static final int MAX_LIMIT = 100;

    @Autowired
    private CupidInboxMapper inboxMapper;

    @Override
    public List<Map<String, Object>> getThreads(String userId)
    {
        List<Map<String, Object>> threads = inboxMapper.selectThreadsByUserId(userId);
        for (Map<String, Object> thread : threads)
        {
            Object lastMessage = thread.get("lastMessage");
            if (lastMessage instanceof String text && text.length() > 120)
            {
                thread.put("lastMessage", text.substring(0, 120));
            }
        }
        return threads;
    }

    @Override
    public Map<String, Object> getMessages(
            String userId, String threadId, String before, int requestedLimit)
    {
        requireOwnedThread(userId, threadId);
        int limit = requestedLimit <= 0 ? DEFAULT_LIMIT : Math.min(requestedLimit, MAX_LIMIT);
        List<Map<String, Object>> rows =
                inboxMapper.selectMessages(threadId, before, limit + 1);
        boolean hasMore = rows.size() > limit;
        List<Map<String, Object>> items = hasMore
                ? new ArrayList<>(rows.subList(0, limit)) : rows;

        Map<String, Object> page = new LinkedHashMap<>();
        page.put("limit", limit);
        page.put("hasMore", hasMore);
        if (hasMore && !items.isEmpty())
        {
            page.put("nextBefore", items.get(items.size() - 1).get("id"));
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("items", items);
        result.put("page", page);
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> markRead(String userId, String threadId)
    {
        requireOwnedThread(userId, threadId);
        inboxMapper.upsertRead(IdUtils.fastUUID(), threadId, userId);
        return inboxMapper.selectRead(threadId, userId);
    }

    @Override
    @Transactional
    public Map<String, Object> sendMessage(String userId, String threadId, String body)
    {
        Map<String, Object> thread = requireOwnedThread(userId, threadId);
        if (!"chat".equals(thread.get("category")) || !"open".equals(thread.get("status")))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "thread_not_writable");
        }
        String message = body == null ? null : body.trim();
        if (!StringUtils.hasText(message) || message.length() > 4000)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_message");
        }
        String messageId = IdUtils.fastUUID();
        inboxMapper.insertMessage(messageId, threadId, userId, message);
        inboxMapper.touchThread(threadId);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", messageId);
        result.put("senderType", "user");
        result.put("messageType", "text");
        result.put("body", message);
        result.put("createdAt", new java.util.Date());
        return result;
    }

    private Map<String, Object> requireOwnedThread(String userId, String threadId)
    {
        Map<String, Object> thread =
                inboxMapper.selectThreadByIdAndUserId(threadId, userId);
        if (thread == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "thread_not_found");
        }
        return thread;
    }
}
