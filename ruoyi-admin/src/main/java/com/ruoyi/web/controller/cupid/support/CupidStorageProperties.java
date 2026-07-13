package com.ruoyi.web.controller.cupid.support;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Public image storage configuration.
 */
@Component
@ConfigurationProperties(prefix = "cupid.storage")
public class CupidStorageProperties
{
    private String type = "local";

    private String localRoot;

    private String publicBaseUrl;

    private final S3 s3 = new S3();

    public String getType()
    {
        return type;
    }

    public void setType(String type)
    {
        this.type = type;
    }

    public String getLocalRoot()
    {
        return localRoot;
    }

    public void setLocalRoot(String localRoot)
    {
        this.localRoot = localRoot;
    }

    public String getPublicBaseUrl()
    {
        return publicBaseUrl;
    }

    public void setPublicBaseUrl(String publicBaseUrl)
    {
        this.publicBaseUrl = publicBaseUrl;
    }

    public S3 getS3()
    {
        return s3;
    }

    public static class S3
    {
        private String bucket;

        private String privateBucket;

        private String region = "auto";

        private String endpoint;

        private String accessKey;

        private String secretKey;

        private boolean pathStyleAccess;

        public String getBucket()
        {
            return bucket;
        }

        public void setBucket(String bucket)
        {
            this.bucket = bucket;
        }

        public String getPrivateBucket()
        {
            return privateBucket == null || privateBucket.isBlank() ? bucket : privateBucket;
        }

        public void setPrivateBucket(String privateBucket)
        {
            this.privateBucket = privateBucket;
        }

        public String getRegion()
        {
            return region;
        }

        public void setRegion(String region)
        {
            this.region = region;
        }

        public String getEndpoint()
        {
            return endpoint;
        }

        public void setEndpoint(String endpoint)
        {
            this.endpoint = endpoint;
        }

        public String getAccessKey()
        {
            return accessKey;
        }

        public void setAccessKey(String accessKey)
        {
            this.accessKey = accessKey;
        }

        public String getSecretKey()
        {
            return secretKey;
        }

        public void setSecretKey(String secretKey)
        {
            this.secretKey = secretKey;
        }

        public boolean isPathStyleAccess()
        {
            return pathStyleAccess;
        }

        public void setPathStyleAccess(boolean pathStyleAccess)
        {
            this.pathStyleAccess = pathStyleAccess;
        }
    }
}
