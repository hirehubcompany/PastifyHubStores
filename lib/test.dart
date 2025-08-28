import 'package:flutter/material.dart';
import 'package:pastifyhubstores/utils/app%20color.dart';
import 'package:sizer/sizer.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search on PastifyHubStores',
            hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.7)),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppColors.textDark),
          ),
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: ListView(
        children: [
          _buildCategorySection(
            title: 'Grocery',
            subcategories: [
              'All Products',
              'Food Cupboard',
              'Cooking Ingredients',
              'Biscuits',
              'Pasta, Noodles & S...',
            ],
          ),
          _buildCategorySection(
            title: 'Phones & Tablets',
            subcategories: [],
          ),
          _buildCategorySection(
            title: 'Health & Beauty',
            subcategories: [],
          ),
          _buildCategorySection(
            title: 'Home & Office',
            subcategories: [],
          ),
          _buildCategorySection(
            title: 'Electronics',
            subcategories: [
              'Canned, Jarred & Pac...',
              'Crisps & Chips',
              'Grains & Rice',
            ],
          ),
          _buildCategorySection(
            title: 'Computing',
            subcategories: [
              'Cooking & Baking',
            ],
          ),
          _buildCategorySection(
            title: 'Fashion',
            subcategories: [],
          ),
          _buildCategorySection(
            title: 'Sporting Goods',
            subcategories: [
              'Flours & Meals',
              'Sugars, Sugar & Sw...',
            ],
          ),
          _buildCategorySection(
            title: 'Baby Products',
            subcategories: [
              'Breakfast Foods',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required List<String> subcategories,
  }) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          if (subcategories.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2.h,
                  crossAxisSpacing: 4.w,
                  childAspectRatio: 1.2,
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        width: 20.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.grey[600],
                          size: 8.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        subcategories[index],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}