import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../screens/detail_screen.dart';
import '../theme/app_tokens.dart';
import 'oud_components.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    final isSoldOut = product.stock == 0;
    final sale = product.isSale && product.salePrice != null;

    return GestureDetector(
      onTap: isSoldOut
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(product: product),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: OudRadii.lg,
          border: Border.all(color: OudColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(22)),
                      child: product.image == null
                          ? Container(color: OudColors.surface)
                          : Image.asset(
                              product.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: OudColors.surface),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (isSoldOut)
                          const OudTag(
                            label: '품절',
                            bgColor: Color(0xCC2F2E2B),
                            textColor: Colors.white,
                          ),
                        if (!isSoldOut && product.isNew)
                          const OudTag(
                            label: '신상',
                            bgColor: OudColors.sage,
                            textColor: Color(0xFF32502E),
                          ),
                        if (!isSoldOut && sale) ...[
                          const SizedBox(width: 6),
                          const OudTag(
                            label: '할인',
                            bgColor: OudColors.primarySoft,
                            textColor: OudColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<UserDataManager>(
                      builder: (_, manager, __) {
                        final fav = manager.isFavorite(product);
                        return GestureDetector(
                          onTap: () => manager.toggleWishlist(product),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white70,
                            child: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: fav ? OudColors.primary : OudColors.text,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: OudColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: OudColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₩${format.format(sale ? product.salePrice! : product.price)}',
                    style: const TextStyle(
                      color: OudColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
