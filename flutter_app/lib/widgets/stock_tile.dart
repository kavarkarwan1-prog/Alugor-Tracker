import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../theme/app_theme.dart';

class StockTile extends StatelessWidget {
  final Stock stock;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const StockTile({
    super.key,
    required this.stock,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  Color _changeColor() {
    if (stock.isUp) return AppColors.priceUp;
    if (stock.isDown) return AppColors.priceDown;
    return AppColors.neutral;
  }

  IconData _changeIcon() {
    if (stock.isUp) return Icons.arrow_drop_up;
    if (stock.isDown) return Icons.arrow_drop_down;
    return Icons.remove;
  }

  @override
  Widget build(BuildContext context) {
    final color = _changeColor();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Text(
                  stock.name.isNotEmpty ? stock.name[0].toUpperCase() : '?',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      stock.price.toStringAsFixed(2),
                      key: ValueKey(stock.price),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_changeIcon(), color: color, size: 18),
                      Text(
                        '${stock.changePercent.abs().toStringAsFixed(2)}%',
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? AppColors.brandAccent : AppColors.neutral,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
