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
1. Provider 主要用于在 Widget 树中传递 context 或管理相对简单的数据。虽然它也能处理一些响应式需求，但相较于 MobX 等专门的响应式状态管理库，Provider 在响应式能力上较为基础。
2. GetX 非常适合处理较为复杂的视图层响应式需求。它的 API 设计简洁易用，对于专注于 UI 开发的场景来说是一个不错的选择。不过，如果需要对数据层进行高度抽象和复杂的响应式处理，MobX 可能更合适。
3. MobX 是一款功能强大的响应式状态管理库，能够满足几乎所有复杂的响应式需求。它可以与 Provider 结合使用，Provider 主要负责 context 传递，MobX 则专注于数据层的响应式处理。

以上为暂时的结论.