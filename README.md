# destroyer
Flutter 状态管理选型

## Getting Started

mobx

build store
```shell
flutter pub run build_runner build
```
通用比较:

|    特征     | 	Provider      | GetX           | MobX            |
|:---------:|----------------|----------------|-----------------|
|   学习曲线    | 平缓             | 中等             | 陡峭              |
|    性能     | 良好             | 优秀             | 优秀              |
|    灵活度    | 高              | 高              | 高               |
|    社区     | 活跃             | 中等             | 活跃              |
|    特点     | 依赖注入，灵活        | 简洁，全能          | 响应式编程，强大        |

FROM GEMINI


结论:
1. Provider 适用于 context 的传递, 或处理简单的数据响应, 在响应式方向啥也不是;
2. GetX 适用于较复杂的响应需求, 但仅限于视图, API 很简洁, 如果只做UI开发, 或都数据不需要高度抽象那么这是一个不错的选择;
3. Mobx 非常强, 几乎可以满足所有响应式需求, 可以结合Provider来处理context.

以上为暂时的结论.