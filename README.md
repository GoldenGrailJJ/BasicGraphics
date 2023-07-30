# 目录

- [1 光照模型 (Lighting Model)](#1 光照模型 (Lighting Model))
- [标题2](#标题2)
- [标题3](#标题3)
- [标题4](#标题4)

# 1 光照模型 (Lighting Model)
1. `return Lambert;`: 这里计算了 Lambert 光照模型的结果，Lambert 模型表示漫反射光照，是**光线与表面法线之间的夹角的余弦值**。

   ![image-20230730101443854](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730101443854.png)

2. `return HalfLambert;`: 这里计算了 Half Lambert 光照模型的结果，Half Lambert 模型将 Lambert 模型的结果进行了平方，使得**光照在侧面更明亮**。

   ![image-20230730101846276](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730101846276.png)

   

3. `return step(0.5, HalfLambert);`: 在 Half Lambert 光照的基础上，使用 step 函数对光照进行**二分明暗处理**，小于 0.5 的部分显示黑色，大于等于 0.5 的部分显示白色。

   ![image-20230730102244018](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730102244018.png)

4. `return floor( (NL * 0.5 + 0.5) * 5 ) / 5;`: 在 Half Lambert 光照的基础上，根据法线与光线夹角的大小，将光照值划分为 5 个等级，每个等级都用不同的颜色显示。实现**多分明暗**。

   ![image-20230730102357307](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730102357307.png)

5. `return Phong;`: 这里计算了 Phong 光照模型的结果，Phong 模型是一种高光反射模型，是通过计算**反射光线与视角之间的夹角**来模拟高光效果。

   ![image-20230730103401627](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730103401627.png)

6. `return BlinPhong;`: 这里计算了 BlinPhong 光照模型的结果，BlinPhong 模型是 Phong 模型的一种变种，使用**半角向量来代替反射光线进行高光计算**。

   ![image-20230730103321115](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730103321115.png)

   > 1. Phong 光照模型：
   >    - Phong 光照模型是由Bui Tuong Phong在1973年提出的，是最早的光照模型之一。
   >    - 计算高光时，使用视角方向（View Direction）和反射光方向（Reflection Direction）之间的夹角来控制高光强度。
   >    - **高光通常呈现较为尖锐和明亮的外观，高光区域会更集中和窄。**
   >    - 由于使用反射光方向计算高光，Phong 光照模型的计算相对较为复杂，对于较大的高光指数可能会产生不真实的结果，即"镜面爆炸"现象。
   > 2. Blinn-Phong 光照模型：
   >    - Blinn-Phong 光照模型是由Jim Blinn在1977年提出的，是对Phong模型的改进和简化。
   >    - 计算高光时，使用视角方向（View Direction）和半角向量（Halfway Vector）之间的夹角来控制高光强度。
   >    - 半角向量是入射光方向与视角方向的中间向量，计算相对较简单，避免了Phong模型中的复杂反射计算。
   >    - **高光通常呈现较为柔和和宽阔的外观，高光区域更加平滑。**
   >    - Blinn-Phong 光照模型相对于Phong模型计算效率更高，且能够更准确地模拟高光效果。

7. `return Diffuse + Specular;`: 在 Lambert 光照的基础上，加上 BlinPhong 光照的结果，实现漫反射与高光的组合效果。

   ![image-20230730103446629](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730103446629.png)

8. `return BackLight;`: 这里计算了 BackLight 光照模型的结果，BackLight 模型模拟了背光效果，是根据**表面法线与视角之间的夹角**来模拟背光照明。

   ![image-20230730103516292](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730103516292.png)



9.`FinalColor = (Diffuse + BackLight) * BaseColor + Specular;` 这一行代码计算最终的颜色。`Diffuse` 是之前计算的漫反射效果，`BackLight` 是背光效果，`BaseColor` 是纹理采样的基础颜色，`Specular` 是高光效果。将它们组合起来得到最终的颜色

![image-20230730103716550](C:\Users\10571\AppData\Roaming\Typora\typora-user-images\image-20230730103716550.png)

# 标题2

这是标题2的内容。

# 标题3
这是标题3的内容。

# 标题4
这是标题4的内容。