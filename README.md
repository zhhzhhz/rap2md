# rap2md

## Authority

zhhzhhz#163.com

2019-01-23

## Description

解析rap接口文档的json数据，自动生成markdown格式的API文档

适用于RAP 1



## Usage

1. 登录rap，打开项目

2. 借助浏览器的F12调试模式，刷新页面，获取/workspace/loadWorkspace.do接口返回的项目json数据，保存为api.json

3. 执行lua rap2md 完成后生成api.md文档


## Remark

需要安装lua5.1

如果rap文档的备注中，包含“可选字段”，则生成的md文档中可选为"Yes"，否则为空



