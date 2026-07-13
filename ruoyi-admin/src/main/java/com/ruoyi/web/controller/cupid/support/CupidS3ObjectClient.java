package com.ruoyi.web.controller.cupid.support;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import jakarta.annotation.PreDestroy;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3ClientBuilder;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

@Component
@ConditionalOnProperty(prefix = "cupid.storage", name = "type", havingValue = "s3")
public class CupidS3ObjectClient
{
    private final S3Client client;

    public CupidS3ObjectClient(CupidStorageProperties properties)
    {
        CupidStorageProperties.S3 config = properties.getS3();
        if (isBlank(config.getBucket()))
        {
            throw new IllegalStateException("CUPID_STORAGE_S3_BUCKET is required for s3 storage");
        }
        S3ClientBuilder builder = S3Client.builder()
                .region(Region.of(isBlank(config.getRegion()) ? "auto" : config.getRegion()))
                .serviceConfiguration(S3Configuration.builder()
                        .pathStyleAccessEnabled(config.isPathStyleAccess())
                        .build());
        if (!isBlank(config.getEndpoint()))
        {
            builder.endpointOverride(URI.create(config.getEndpoint()));
        }
        if (!isBlank(config.getAccessKey()) || !isBlank(config.getSecretKey()))
        {
            if (isBlank(config.getAccessKey()) || isBlank(config.getSecretKey()))
            {
                throw new IllegalStateException("Both S3 access key and secret key must be configured");
            }
            builder.credentialsProvider(StaticCredentialsProvider.create(
                    AwsBasicCredentials.create(config.getAccessKey(), config.getSecretKey())));
        }
        else
        {
            builder.credentialsProvider(DefaultCredentialsProvider.create());
        }
        this.client = builder.build();
    }

    public void put(String bucket, String objectKey, MultipartFile file) throws IOException
    {
        put(bucket, objectKey, file, file.getContentType());
    }

    public void put(String bucket, String objectKey, MultipartFile file, String contentType) throws IOException
    {
        String key = CupidStoragePaths.requireObjectKey(objectKey);
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .contentLength(file.getSize())
                .build();
        client.putObject(request, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
    }

    public CupidStoredObject open(String bucket, String objectKey) throws IOException
    {
        String key = CupidStoragePaths.requireObjectKey(objectKey);
        try
        {
            ResponseInputStream<GetObjectResponse> input = client.getObject(GetObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .build());
            GetObjectResponse response = input.response();
            return new CupidStoredObject(input,
                    isBlank(response.contentType()) ? "application/octet-stream" : response.contentType(),
                    response.contentLength() == null ? -1L : response.contentLength());
        }
        catch (S3Exception e)
        {
            if (e.statusCode() == 404)
            {
                throw new FileNotFoundException(objectKey);
            }
            throw e;
        }
    }

    public void delete(String bucket, String objectKey)
    {
        client.deleteObject(DeleteObjectRequest.builder()
                .bucket(bucket)
                .key(CupidStoragePaths.requireObjectKey(objectKey))
                .build());
    }

    @PreDestroy
    public void close()
    {
        client.close();
    }

    private static boolean isBlank(String value)
    {
        return value == null || value.isBlank();
    }
}
