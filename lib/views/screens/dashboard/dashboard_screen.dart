import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/transaction_viewmodel.dart';
import '../../../viewmodels/news_viewmodel.dart';
import '../../../models/transaction_model.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/transaction_bottom_sheet.dart';
import '../../widgets/news_card.dart';
import '../../widgets/skeleton_widgets.dart';
import '../auth/login_screen.dart';
import '../transactions/transactions_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  void _openAddTransaction(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(
        onSave: ({
          required title,
          required amount,
          required date,
          required type,
          required category,
          description,
        }) async {
          await ref
              .read(transactionViewModelProvider(userId).notifier)
              .addTransaction(
                title: title,
                amount: amount,
                date: date,
                type: type,
                category: category,
                description: description,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transação adicionada!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authViewModelProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (user == null) {
      return const LoginScreen();
    }

    final txState = ref.watch(transactionViewModelProvider(user.id));
    final newsState = ref.watch(newsViewModelProvider);

    final pages = [
      _HomeTab(
        user: user,
        txState: txState,
        newsState: newsState,
        onAddTransaction: () => _openAddTransaction(user.id),
        onDeleteTransaction: (id) {
          ref
              .read(transactionViewModelProvider(user.id).notifier)
              .deleteTransaction(id);
        },
        onEditTransaction: (tx) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TransactionBottomSheet(
              transaction: tx,
              onSave: ({
                required title,
                required amount,
                required date,
                required type,
                required category,
                description,
              }) async {
                await ref
                    .read(transactionViewModelProvider(user.id).notifier)
                    .updateTransaction(
                      tx.copyWith(
                        title: title,
                        amount: amount,
                        date: date,
                        type: type,
                        category: category,
                        description: description,
                      ),
                    );
              },
            ),
          );
        },
        onRefreshNews: () =>
            ref.read(newsViewModelProvider.notifier).refresh(),
      ),
      TransactionsScreen(userId: user.id),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddTransaction(user.id),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova transação'),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ).animate().scale(delay: 500.ms, curve: Curves.elasticOut)
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transações',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final UserModel user;
  final TransactionState txState;
  final NewsState newsState;
  final VoidCallback onAddTransaction;
  final Function(String) onDeleteTransaction;
  final Function(TransactionModel) onEditTransaction;
  final VoidCallback onRefreshNews;

  const _HomeTab({
    required this.user,
    required this.txState,
    required this.newsState,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.onEditTransaction,
    required this.onRefreshNews,
  });

  @override
  Widget build(BuildContext context) {
    final recentTransactions = txState.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FinanceApp'),
        actions: [
          Consumer(
            builder: (context, ref, _) => IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair da sua conta?'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(authViewModelProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onRefreshNews();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: txState.isLoading
                  ? const SkeletonBalanceCard()
                  : BalanceCard(
                      balance: txState.balance,
                      totalIncome: txState.totalIncome,
                      totalExpense: txState.totalExpense,
                      userName: user.name,
                    ),
            ),

            // News section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notícias Financeiras',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.primary),
                      onPressed: onRefreshNews,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 195,
                child: newsState.isLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (_, __) => const SkeletonNewsCard(),
                      )
                    : newsState.errorMessage != null
                        ? Center(
                            child: Text(
                              newsState.errorMessage!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: newsState.articles.length,
                            itemBuilder: (_, i) =>
                                NewsCard(article: newsState.articles[i]),
                          ),
              ),
            ),

            // Recent transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transações Recentes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (txState.transactions.length > 5)
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todas'),
                      ),
                  ],
                ),
              ),
            ),

            if (txState.isLoading)
              const SliverToBoxAdapter(child: SkeletonList(count: 3))
            else if (recentTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma transação ainda',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para adicionar sua primeira transação',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => TransactionCard(
                    transaction: recentTransactions[i],
                    index: i,
                    onDelete: () =>
                        onDeleteTransaction(recentTransactions[i].id),
                    onEdit: () => onEditTransaction(recentTransactions[i]),
                  ),
                  childCount: recentTransactions.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
