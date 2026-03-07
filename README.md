# 设备监测系统 Monitoring System

本仓库包含 Flutter 前端、FastAPI 后端，以及本地 AI 训练/部署脚本。

## 目录总览

```text
monitoring_system/
├── lib/                  # Flutter 前端代码
├── backend/              # FastAPI 后端代码
├── local_ai/             # 本地模型相关配置与说明
├── docs/                 # 项目文档
├── archives/             # 历史压缩包
└── *.bat                 # Windows 启停与训练脚本
```

## 常用入口

- 快速开始：`docs/QUICK_START.md`
- 前端说明：`docs/README_UI.md`
- 架构说明：`docs/ARCHITECTURE.md`
- 实现总结：`docs/IMPLEMENTATION_SUMMARY.md`
- 后端说明：`backend/README.md`

## Windows 常用命令

- 启动前后端：`start_all.bat`
- 停止全部服务：`stop_all.bat`
- 仅启动后端：`start_backend.bat`

## 说明

- 当前仓库保留根目录脚本位置不变，以避免影响训练/部署与批处理调用链。
