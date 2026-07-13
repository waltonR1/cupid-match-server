# Cupid Match 图片存储配置

公开资料图片使用统一存储接口，支持服务器本地磁盘、AWS S3 和兼容 S3 协议的 Cloudflare R2。前端上传接口和图片地址保持不变。

## 文件分类

| 类型 | 上传接口 | 返回值 | 存储策略 |
| --- | --- | --- | --- |
| 头像、资料照片等公开图片 | `POST /api/upload` | `/profile/upload/yyyy/MM/dd/{uuid}.{ext}` | local 或 s3 |
| 实名、学历、收入等认证材料 | `POST /api/account/profiles/{profileId}/verification/materials/upload` | `private://verification/...` | local 或 s3 私有空间 |

认证材料仍通过后台鉴权接口预览和下载，不会被 `/profile/**` 公开访问，也不会跳转到 CDN。

## 公开图片读取

前端始终读取后端返回的 `/profile/upload/...` 相对地址，后端根据配置选择：

- `CUPID_STORAGE_PUBLIC_BASE_URL` 留空：后端从本地或对象存储读取并代理文件内容。
- `CUPID_STORAGE_PUBLIC_BASE_URL` 有值：后端返回 `302`，浏览器直接访问对象公共域名或 CDN。

因此接入或更换 CDN 不需要修改数据库中的旧图片地址。

资料保存时会对比旧、新照片列表；被移除的 `/profile/upload/...` 文件会在数据库保存成功后从当前存储中删除。删除存储对象失败只记录告警，不会回滚已经成功的资料保存。

## 本地模式

```env
CUPID_STORAGE_TYPE=local
CUPID_STORAGE_LOCAL_ROOT=/var/lib/cupid-match/storage
CUPID_STORAGE_PUBLIC_BASE_URL=
```

图片实际保存到：

```text
/var/lib/cupid-match/storage/upload/yyyy/MM/dd/{uuid}.{ext}
```

私有认证材料继续使用兼容旧版本的目录：

```text
/var/lib/cupid-match/cupid-private/verification/{profileId}/yyyy/MM/dd/{uuid}.{ext}
```

未设置 `CUPID_STORAGE_LOCAL_ROOT` 时，默认使用 `${user.home}/.cupid-match/storage`。

## AWS S3

```env
CUPID_STORAGE_TYPE=s3
CUPID_STORAGE_S3_BUCKET=cupid-match-images
CUPID_STORAGE_S3_PRIVATE_BUCKET=cupid-match-private
CUPID_STORAGE_S3_REGION=eu-west-3
CUPID_STORAGE_S3_ENDPOINT=
CUPID_STORAGE_S3_ACCESS_KEY=
CUPID_STORAGE_S3_SECRET_KEY=
CUPID_STORAGE_S3_PATH_STYLE_ACCESS=false
CUPID_STORAGE_PUBLIC_BASE_URL=
```

访问密钥留空时使用 AWS SDK 默认凭据链，适合 IAM Role、ECS 或 EKS。私有桶留空时复用公开桶；即使复用，也只有公开图片会使用 `PUBLIC_BASE_URL`。`PUBLIC_BASE_URL` 留空时公开图片读取流量经过后端。

## Cloudflare R2

```env
CUPID_STORAGE_TYPE=s3
CUPID_STORAGE_S3_BUCKET=cupid-match-images
CUPID_STORAGE_S3_PRIVATE_BUCKET=cupid-match-private
CUPID_STORAGE_S3_REGION=auto
CUPID_STORAGE_S3_ENDPOINT=https://<ACCOUNT_ID>.r2.cloudflarestorage.com
CUPID_STORAGE_S3_ACCESS_KEY=<R2_ACCESS_KEY_ID>
CUPID_STORAGE_S3_SECRET_KEY=<R2_SECRET_ACCESS_KEY>
CUPID_STORAGE_S3_PATH_STYLE_ACCESS=false
CUPID_STORAGE_PUBLIC_BASE_URL=
```

先让 `PUBLIC_BASE_URL` 留空即可通过后端代理读取。后续绑定 R2 自定义域名或 CDN 后再设置：

```env
CUPID_STORAGE_PUBLIC_BASE_URL=https://images.example.com
```

该域名根路径需要对应同一个 bucket，对象 key 保持 `upload/yyyy/MM/dd/...`。

私有材料对象 key 使用 `private/verification/...`。R2/S3 bucket 必须保持私有，后台会使用服务端凭据读取并转发文件。

## 代码位置

- 上传入口：`ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidUploadController.java`
- 读取入口：`ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidPublicImageController.java`
- 存储接口：`ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/support/CupidPublicImageStorage.java`
- 本地实现：`LocalCupidPublicImageStorage.java`
- S3/R2 实现：`S3CupidPublicImageStorage.java`
- 私有认证材料：`CupidVerificationMaterialStorage.java`

## 验收

1. 上传图片后确认接口仍返回 `/profile/upload/...`。
2. 直接请求该地址，代理模式应返回图片内容。
3. 配置 `CUPID_STORAGE_PUBLIC_BASE_URL` 后，同一地址应返回指向 CDN 的 `302`。
4. 上传认证材料后应返回 `private://verification/...`，且不能通过 `/profile/**` 或 CDN 直接读取。
5. 使用有审核权限的后台账号预览和下载认证材料，确认响应包含 `Cache-Control: no-store`。
