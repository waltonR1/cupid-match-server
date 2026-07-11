# Cupid Match 上传与 CDN 配置

本文只说明当前已经落地的上传链路，以及部署时需要填写哪些配置。结论先放前面：当前已经分成两类文件，公开图片可以通过 CDN 回源接入；认证材料保持私有存储，不走公开 CDN。

## 当前结论

| 类型 | 上传接口 | 保存位置 | 返回值 | 是否走公开 CDN |
| --- | --- | --- | --- | --- |
| 头像、资料照片等公开图片 | `POST /api/upload` | `ruoyi.profile/upload/...` | `/profile/upload/yyyy/MM/dd/{uuid}.{ext}` | 可以 |
| 实名、学历、收入、婚姻等认证材料 | `POST /api/account/profiles/{profileId}/verification/materials/upload` | `cupid-private/verification/...` | `private://verification/...` | 不可以 |

公开图片会通过 RuoYi 静态资源映射暴露为 `/profile/**`。认证材料只保存私有引用，不会拼接公开资源域名，也不会被 `/profile/**` 访问到。

## 部署时需要填写什么

### 后端

后端只需要确认 `ruoyi.profile` 是服务器上的本地上传目录：

```yaml
ruoyi:
  profile: /home/ruoyi/uploadPath
```

注意：这里是文件系统路径，不是 URL，也不是 CDN 域名。

### C 端前端

C 端通过 `VITE_ASSET_BASE_URL` 决定公开图片最终访问域名：

```env
VITE_ASSET_BASE_URL=https://cdn.example.com
```

如果暂时不接 CDN，也可以直接填后端域名：

```env
VITE_ASSET_BASE_URL=https://api.example.com
```

前端会把后端返回的 `/profile/upload/...` 拼成：

```text
https://cdn.example.com/profile/upload/...
```

认证材料返回的是 `private://verification/...`，不会使用 `VITE_ASSET_BASE_URL`。

### CDN

如果使用 CDN 回源模式，只需要在 CDN 平台配置：

```text
CDN 域名: https://cdn.example.com
源站: 后端服务或 Nginx
需要可回源路径: /profile/**
```

也就是说，浏览器访问：

```text
https://cdn.example.com/profile/upload/...
```

CDN 能回源到：

```text
https://api.example.com/profile/upload/...
```

即可。

## 代码位置

### 公开图片上传

后端入口：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidUploadController.java
```

静态资源映射：

```text
ruoyi-framework/src/main/java/com/ruoyi/framework/config/ResourcesConfig.java
```

映射关系：

```text
/profile/** -> ruoyi.profile
```

C 端调用：

```text
cupid-match-app/src/api/upload/upload.ts
```

其中 `uploadImage(...)` 会调用 `/api/upload` 并保留后端返回的 `/profile/...` 相对路径；页面展示时再通过 `resolveAssetUrl(...)` 拼接 `VITE_ASSET_BASE_URL`。

### 私有认证材料上传

后端入口：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidAccountController.java
```

实际存储：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/support/CupidVerificationMaterialStorage.java
```

C 端调用：

```text
cupid-match-app/src/api/upload/upload.ts
```

其中 `uploadVerificationMaterial(...)` 只返回后端的私有材料引用，不做 CDN 拼接。

## 现在是否只需要改配置

如果目标是“公开图片通过 CDN 加速，文件仍由后端本地磁盘保存”，是的，只需要：

1. 后端部署时设置好 `ruoyi.profile`。
2. CDN 配好 `/profile/**` 回源。
3. C 端部署时把 `VITE_ASSET_BASE_URL` 填成 CDN 域名。

C 端会尽量保存 `/profile/...` 相对路径，展示时再拼资源域名。这样后续更换 CDN 域名时，一般只需要改部署配置，不需要批量迁移旧图片数据。

如果目标是“文件直接上传对象存储，例如 S3、OSS、COS、R2”，那不是只改配置，需要新增后端存储实现。到那一步建议再抽象统一的文件存储服务，公开图片和私有材料分别走 public/private bucket 或 key 前缀。

## 验收方式

1. 上传一张头像或资料照片。
2. 数据库或接口返回值优先保持 `/profile/upload/...`。
3. 页面图片应能通过 `VITE_ASSET_BASE_URL + /profile/upload/...` 访问。
4. 上传认证材料后，返回值应为 `private://verification/...`。
5. 认证材料不应能通过 CDN 域名或 `/profile/**` 直接访问。
