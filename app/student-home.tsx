import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import { supabase } from '../lib/supabase';

type Profile = {
  name: string;
  role: string;
};

type Transaction = {
  id: string;
  type: 'credit' | 'debit';
  amount: number;
  description: string;
  created_at: string;
};

export default function StudentHomeScreen() {
  const [profile, setProfile] = useState<Profile | null>(null);
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  async function loadDashboard() {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        router.replace('/login');
        return;
      }

      const { data: profileData, error: profileError } =
        await supabase
          .from('profiles')
          .select('name, role')
          .eq('id', user.id)
          .single();

      if (profileError) {
        console.error(
          'Erro ao carregar perfil:',
          profileError.message
        );

        return;
      }

      setProfile(profileData);

      const { data: walletData, error: walletError } =
        await supabase
          .from('wallets')
          .select('id, balance')
          .eq('student_id', user.id)
          .single();

      if (walletError) {
        console.error(
          'Erro ao carregar carteira:',
          walletError.message
        );

        return;
      }

      setBalance(Number(walletData.balance));

      const { data: transactionsData, error: transactionsError } =
        await supabase
          .from('wallet_transactions')
          .select('id, type, amount, description, created_at')
          .eq('wallet_id', walletData.id)
          .order('created_at', {
            ascending: false,
          })
          .limit(5);

      if (transactionsError) {
        console.error(
          'Erro ao carregar transações:',
          transactionsError.message
        );

        return;
      }

      setTransactions(
        (transactionsData || []).map((transaction) => ({
          ...transaction,
          amount: Number(transaction.amount),
        }))
      );
    } finally {
      setLoading(false);
    }
  }

  async function handleLogout() {
    await supabase.auth.signOut();

    router.replace('/login');
  }

  function formatCurrency(value: number) {
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    });
  }

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString('pt-BR');
  }

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator
          size="large"
          color="#1B5E20"
        />
      </View>
    );
  }

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <View style={styles.headerText}>
          <Text style={styles.greeting}>
            Olá, {profile?.name || 'Aluno'} 👋
          </Text>

          <Text style={styles.headerSubtitle}>
            Continue sua jornada financeira.
          </Text>
        </View>

        <Pressable onPress={handleLogout}>
          <Text style={styles.logoutText}>
            Sair
          </Text>
        </Pressable>
      </View>

      <View style={styles.balanceCard}>
        <Text style={styles.balanceLabel}>
          Saldo virtual
        </Text>

        <Text style={styles.balanceValue}>
          {formatCurrency(balance)}
        </Text>

        <Text style={styles.balanceDescription}>
          Complete atividades para aumentar seu saldo e
          utilizá-lo nos investimentos simulados.
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>
          Movimentações recentes
        </Text>

        {transactions.length === 0 ? (
          <View style={styles.emptyCard}>
            <Text style={styles.emptyText}>
              Nenhuma movimentação encontrada.
            </Text>
          </View>
        ) : (
          <View style={styles.transactionsCard}>
            {transactions.map((transaction) => (
              <View
                key={transaction.id}
                style={styles.transactionItem}
              >
                <View style={styles.transactionInfo}>
                  <Text style={styles.transactionDescription}>
                    {transaction.description}
                  </Text>

                  <Text style={styles.transactionDate}>
                    {formatDate(transaction.created_at)}
                  </Text>
                </View>

                <Text
                  style={[
                    styles.transactionAmount,
                    transaction.type === 'credit'
                      ? styles.creditAmount
                      : styles.debitAmount,
                  ]}
                >
                  {transaction.type === 'credit' ? '+' : '-'}{' '}
                  {formatCurrency(transaction.amount)}
                </Text>
              </View>
            ))}
          </View>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>
          Seu progresso
        </Text>

        <View style={styles.progressCard}>
          <View style={styles.progressHeader}>
            <Text style={styles.progressText}>
              Educação Financeira
            </Text>

            <Text style={styles.progressPercentage}>
              0%
            </Text>
          </View>

          <View style={styles.progressBackground}>
            <View style={styles.progressBar} />
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>
          Continue aprendendo
        </Text>

        <Pressable style={styles.lessonCard}>
          <View style={styles.lessonIcon}>
            <Text style={styles.lessonEmoji}>
              📚
            </Text>
          </View>

          <View style={styles.lessonContent}>
            <Text style={styles.lessonTitle}>
              Introdução à Educação Financeira
            </Text>

            <Text style={styles.lessonDescription}>
              Aprenda os primeiros conceitos sobre organização
              financeira.
            </Text>
          </View>
        </Pressable>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>
          Acesso rápido
        </Text>

        <View style={styles.quickActions}>
          <Pressable style={styles.quickCard}>
            <Text style={styles.quickEmoji}>
              💳
            </Text>

            <Text style={styles.quickTitle}>
              Gastos
            </Text>
          </Pressable>

          <Pressable style={styles.quickCard}>
            <Text style={styles.quickEmoji}>
              📈
            </Text>

            <Text style={styles.quickTitle}>
              Investir
            </Text>
          </Pressable>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
  },

  content: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },

  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F7FA',
  },

  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },

  headerText: {
    flex: 1,
    paddingRight: 20,
  },

  greeting: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1F2937',
  },

  headerSubtitle: {
    fontSize: 15,
    color: '#6B7280',
    marginTop: 6,
  },

  logoutText: {
    color: '#1B5E20',
    fontWeight: '600',
    fontSize: 15,
  },

  balanceCard: {
    backgroundColor: '#1B5E20',
    borderRadius: 20,
    padding: 24,
    marginTop: 30,
  },

  balanceLabel: {
    color: '#D1FAE5',
    fontSize: 15,
  },

  balanceValue: {
    color: '#FFFFFF',
    fontSize: 34,
    fontWeight: 'bold',
    marginTop: 6,
  },

  balanceDescription: {
    color: '#D1FAE5',
    fontSize: 14,
    marginTop: 12,
    lineHeight: 20,
  },

  section: {
    marginTop: 32,
  },

  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 14,
  },

  transactionsCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    paddingHorizontal: 18,
  },

  transactionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },

  transactionInfo: {
    flex: 1,
    paddingRight: 12,
  },

  transactionDescription: {
    fontSize: 15,
    fontWeight: '600',
    color: '#1F2937',
  },

  transactionDate: {
    fontSize: 13,
    color: '#9CA3AF',
    marginTop: 4,
  },

  transactionAmount: {
    fontSize: 15,
    fontWeight: 'bold',
  },

  creditAmount: {
    color: '#1B5E20',
  },

  debitAmount: {
    color: '#B91C1C',
  },

  emptyCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
  },

  emptyText: {
    color: '#6B7280',
    fontSize: 14,
  },

  progressCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
  },

  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },

  progressText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
  },

  progressPercentage: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1B5E20',
  },

  progressBackground: {
    height: 10,
    backgroundColor: '#E5E7EB',
    borderRadius: 10,
    marginTop: 16,
    overflow: 'hidden',
  },

  progressBar: {
    width: '0%',
    height: '100%',
    backgroundColor: '#1B5E20',
  },

  lessonCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 18,
    flexDirection: 'row',
  },

  lessonIcon: {
    width: 50,
    height: 50,
    backgroundColor: '#E8F5E9',
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },

  lessonEmoji: {
    fontSize: 24,
  },

  lessonContent: {
    flex: 1,
    marginLeft: 14,
  },

  lessonTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1F2937',
  },

  lessonDescription: {
    fontSize: 14,
    color: '#6B7280',
    lineHeight: 20,
    marginTop: 5,
  },

  quickActions: {
    flexDirection: 'row',
    gap: 14,
  },

  quickCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    paddingVertical: 22,
    alignItems: 'center',
  },

  quickEmoji: {
    fontSize: 28,
  },

  quickTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#374151',
    marginTop: 8,
  },
});