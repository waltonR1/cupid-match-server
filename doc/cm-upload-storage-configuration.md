# Cupid Match 上传与 CDN 接入说明

本文说明当前图片和材料上传的处理方式，以及后续接入 CDN / 对象存储时应改动的位置。

## 当前上传链路

### C 端图片上传

C 端头像和资料照片调用：

```text
POST /api/upload
```

后端入口：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidUploadController.java
```

当前实现：

1. 校验文件非空。
2. 只允许 `jpg`、`jpeg`、`png`、`webp`。
3. 通过 `FileUploadUtils.upload(...)` 写入本地磁盘。
4. 返回 `/profile/upload/yyyy/MM/dd/{uuid}.{ext}`。

本地磁盘根目录来自：

```text
ruoyi.profile
```

当前资源访问由 RuoYi 静态资源映射提供：

```text
ruoyi-framework/src/main/java/com/ruoyi/framework/config/ResourcesConfig.java
```

它把 `/profile/**` 映射到 `ruoyi.profile` 目录。

### 认证材料上传

C 端实名认证、学历、收入、婚姻等材料调用：

```text
POST /api/account/profiles/{profileId}/verification/materials/upload
```

后端入口：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/app/CupidAccountController.java
```

实际存储类：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/support/CupidVerificationMaterialStorage.java
```

当前实现也是写本地磁盘，但材料路径与公开图片分开，避免和公开资料图片混在一起。

### RuoYi 原始通用上传

后台框架自带：

```text
POST /common/upload
POST /common/uploads
```

入口：

```text
ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/CommonController.java
```

这是 RuoYi 原始能力。Cupid C 端资料上传主要不走这里。

## 前端调用点

C 端上传封装：

```text
cupid-match-app/src/api/upload/upload.ts
```

其中：

- `uploadImage(...)` 调 `/api/upload`，用于头像、资料照片。
- `uploadVerificationMaterial(...)` 调认证材料上传接口。

前端会通过 `resolveAssetUrl(...)` 把后端返回的相对 URL 解析为可访问资源地址。

## 接 CDN / 对象存储时改哪里

推荐新增一个后端存储抽象，而不是在 Controller 里直接写 CDN SDK。

建议改动点：

1. 新增存储服务接口，例如 `CupidFileStorageService`。
2. 提供两个实现：
   - `local`：保留当前本地磁盘实现；
   - `object-storage`：上传到 S3、OSS、COS、R2 等对象存储。
3. `CupidUploadController` 改为调用该服务。
4. `CupidVerificationMaterialStorage` 改为调用该服务或拆成同一套存储策略。
5. `.env` 增加对象存储配置，例如 bucket、region、endpoint、public base URL。
6. 数据库仍保存最终可访问 URL，不保存临时本地路径。

CDN 接入后，公开图片建议返回 CDN URL；认证材料可以按权限策略选择：

- 后台审核需要长期访问：保存私有对象 key，后端生成临时签名 URL；
- 简化实现：保存受控访问 URL，但不要放到公开 CDN 路径。

## 当前需要注意

- 当前上传文件保存在应用服务器本地磁盘，应用迁移或多实例部署时需要同步文件。
- 当前公开图片 URL 是 `/profile/...`，生产环境需要确保 Nginx 或 Spring 静态资源能访问该路径。
- 接多实例部署前，建议优先切对象存储，否则不同实例之间看不到彼此上传的文件。

