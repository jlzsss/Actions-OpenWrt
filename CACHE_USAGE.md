# 缓存系统使用说明

## 概述

本仓库实现了一套高效的缓存机制，用于显著减少 OpenWrt 编译过程中的重复操作时间消耗，并优化磁盘空间占用。缓存系统具备智能缓存策略、自动过期管理、空间淘汰机制等特性。

## 核心特性

### 1. 自动识别可缓存资源类型
- **dl**: 下载的源码包
- **build_dir**: 编译产物
- **staging_dir**: 工具链和暂存文件
- **tmp**: 临时文件
- **ccache**: 编译器缓存
- **openwrt**: 源码树

### 2. 智能缓存策略
- **缓存键生成**: 基于缓存类型、标识符和配置文件哈希值生成唯一缓存键
- **缓存过期策略**: 不同类型的缓存有不同的过期时间
  - dl: 7天
  - build_dir: 7天
  - staging_dir: 30天
  - tmp: 1天
  - ccache: 30天
  - openwrt: 7天
- **空间淘汰机制**: 当缓存总大小超过限制时，自动淘汰最旧的缓存条目

### 3. 缓存有效性验证
- 自动验证缓存元数据完整性
- 检查缓存是否过期
- 验证缓存类型匹配

### 4. 缓存管理操作
- 手动清理缓存
- 导出/导入缓存
- 缓存统计信息

### 5. 统计功能
- 缓存命中率
- 空间节省率
- 总字节保存量
- 缓存条目数量

## 环境变量配置

在 GitHub Actions 工作流中，可以通过以下环境变量配置缓存系统：

```yaml
env:
  CACHE_ROOT: /mnt/cache           # 缓存根目录
  MAX_CACHE_AGE_DAYS: 7           # 最大缓存天数
  MAX_CACHE_SIZE_GB: 50            # 最大缓存大小（GB）
```

## 使用方法

### 在工作流中集成缓存

缓存系统已自动集成到现有的工作流中，包括：
- [build-immortalwrt.yml](.github/workflows/build-immortalwrt.yml)
- [build-lede.yml](.github/workflows/build-lede.yml)

每个编译阶段都会：
1. 初始化缓存系统
2. 尝试恢复缓存
3. 执行编译任务
4. 保存新的缓存

### 手动使用缓存管理脚本

缓存管理脚本位于 [scripts/cache-manager.sh](scripts/cache-manager.sh)，提供以下命令：

#### 初始化缓存系统
```bash
./scripts/cache-manager.sh init
```

#### 存储缓存
```bash
./scripts/cache-manager.sh store <type> <source_path> [identifier]
```

示例：
```bash
./scripts/cache-manager.sh store dl /workdir/openwrt/dl
./scripts/cache-manager.sh store ccache /mnt/ccache
```

#### 恢复缓存
```bash
./scripts/cache-manager.sh restore <type> <dest_path> [identifier]
```

示例：
```bash
./scripts/cache-manager.sh restore dl /mnt/openwrt/dl
./scripts/cache-manager.sh restore ccache /mnt/ccache
```

#### 清理缓存
```bash
# 清理所有缓存
./scripts/cache-manager.sh clear

# 清理特定类型的缓存
./scripts/cache-manager.sh clear dl
```

#### 查看统计信息
```bash
./scripts/cache-manager.sh stats
```

输出示例：
```
[2026-01-19 10:30:45] [INFO] Cache Statistics:
====================
Cache Version: 1.0
Cache Root: /mnt/cache
Max Cache Age: 7 days
Max Cache Size: 50 GB

Performance Metrics:
  Cache Hits: 15
  Cache Misses: 3
  Cache Saves: 12
  Cache Evictions: 2

Storage Metrics:
  Total Bytes Saved: 5.2GiB
  Total Bytes Stored: 8.7GiB
  Cache Hit Rate: 83.33%

Current Cache Usage:
  dl (downloaded source packages):
    Size: 2.1GiB
    Entries: 3
  build_dir (build artifacts):
    Size: 1.8GiB
    Entries: 2
  staging_dir (toolchain and staging):
    Size: 3.2GiB
    Entries: 1
  tmp (temporary files):
    Size: 256MiB
    Entries: 4
  ccache (compiler cache):
    Size: 1.5GiB
    Entries: 1
  openwrt (source tree):
    Size: 890MiB
    Entries: 1
  Total: 9.7GiB
```

#### 验证缓存
```bash
# 验证所有缓存
./scripts/cache-manager.sh validate

# 验证特定类型的缓存
./scripts/cache-manager.sh validate dl
```

#### 清理过期缓存
```bash
./scripts/cache-manager.sh cleanup
```

#### 导出缓存
```bash
./scripts/cache-manager.sh export [path]
```

默认导出到 `/mnt/cache/export.tar.gz`

#### 导入缓存
```bash
./scripts/cache-manager.sh import <path>
```

## 工作原理

### 缓存键生成
缓存键由三部分组成：
1. 缓存类型（如 dl、build_dir）
2. 标识符（默认为 "default"）
3. 配置文件哈希（基于 .config 文件的 SHA256 值）

这确保了：
- 不同类型的缓存不会冲突
- 相同配置的编译可以复用缓存
- 配置变化时会自动使用新缓存

### 缓存存储结构
```
/mnt/cache/
├── .cache-metadata          # 缓存系统元数据
├── .cache-stats             # 缓存统计信息
├── cache.log                # 缓存操作日志
├── dl/                     # 下载的源码包缓存
│   └── <hash>/             # 基于缓存键的哈希值
│       ├── .metadata        # 缓存条目元数据
│       └── ...             # 缓存内容
├── build_dir/              # 编译产物缓存
├── staging_dir/            # 工具链和暂存文件缓存
├── tmp/                   # 临时文件缓存
├── ccache/                # 编译器缓存
└── openwrt/               # 源码树缓存
```

### 缓存过期机制
1. 每个缓存条目在创建时记录时间戳
2. 恢复缓存时检查是否超过最大存活时间
3. 过期的缓存条目会被自动删除

### 空间淘汰机制
1. 当缓存总大小超过 `MAX_CACHE_SIZE_GB` 时触发淘汰
2. 按缓存条目的创建时间排序
3. 优先淘汰超过最大存活时间一半的旧缓存
4. 持续淘汰直到缓存大小在限制范围内

## 性能优化建议

### 1. 调整缓存大小
根据实际磁盘空间调整 `MAX_CACHE_SIZE_GB`：
- 磁盘空间充足：可以增加到 100GB 或更多
- 磁盘空间有限：可以减少到 30GB 或更少

### 2. 调整缓存过期时间
根据编译频率调整 `MAX_CACHE_AGE_DAYS`：
- 每日编译：可以减少到 3-5 天
- 每周编译：可以保持 7 天
- 不定期编译：可以增加到 14-30 天

### 3. 监控缓存命中率
定期查看缓存统计信息：
- 命中率 > 80%：缓存策略良好
- 命中率 50-80%：可能需要调整缓存策略
- 命中率 < 50%：检查配置是否频繁变化

### 4. 定期清理过期缓存
在每次编译前自动执行 `cleanup` 命令，确保缓存系统健康。

## 故障排查

### 缓存未命中
可能原因：
1. 配置文件发生变化
2. 缓存已过期
3. 缓存条目损坏

解决方法：
1. 检查 `.config` 文件是否被修改
2. 查看缓存日志 `cache.log`
3. 运行 `validate` 命令检查缓存完整性

### 缓存占用空间过大
可能原因：
1. 缓存大小限制设置过大
2. 缓存条目未正确清理

解决方法：
1. 调整 `MAX_CACHE_SIZE_GB` 环境变量
2. 手动运行 `clear` 命令清理缓存
3. 运行 `cleanup` 命令清理过期缓存

### 缓存恢复失败
可能原因：
1. 缓存路径权限问题
2. 缓存文件损坏

解决方法：
1. 检查缓存目录权限
2. 运行 `validate` 命令检查缓存完整性
3. 删除损坏的缓存条目

## 最佳实践

1. **定期查看统计信息**：每周查看一次缓存统计，了解缓存效果
2. **合理配置缓存大小**：根据实际磁盘空间和编译需求调整
3. **保持配置稳定**：避免频繁修改 `.config` 文件，提高缓存命中率
4. **定期清理**：在每次编译前自动清理过期缓存
5. **监控磁盘空间**：确保有足够的空间存储缓存

## 技术细节

### 缓存元数据格式
每个缓存条目包含以下元数据：
```
cache_key=<缓存键>
cache_type=<缓存类型>
identifier=<标识符>
created_at=<创建时间戳>
size_bytes=<大小字节数>
version=<缓存系统版本>
```

### 缓存统计指标
- `cache_hits`: 缓存命中次数
- `cache_misses`: 缓存未命中次数
- `cache_saves`: 缓存保存次数
- `cache_evictions`: 缓存淘汰次数
- `total_bytes_saved`: 总节省字节数
- `total_bytes_stored`: 总存储字节数

### 日志记录
所有缓存操作都会记录到 `cache.log` 文件，包括：
- 操作时间
- 操作类型
- 操作结果
- 错误信息

## 扩展性

缓存系统设计为可扩展的，可以轻松添加新的缓存类型：

1. 在 `CACHE_TYPES` 数组中添加新的缓存类型定义
2. 指定缓存类型的描述和最大存活时间
3. 在工作流中添加相应的缓存恢复和保存步骤

## 许可证

本缓存系统遵循仓库的许可证。

## 支持

如有问题或建议，请提交 Issue 或 Pull Request。
