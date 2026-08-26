import { router } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import {
    ActivityIndicator,
    Alert,
    Pressable,
    ScrollView,
    StyleSheet,
    Text,
    TextInput,
    View,
} from 'react-native';

import { supabase } from '../lib/supabase';

type Category =
  | 'food'
  | 'transport'
  | 'education'
  | 'leisure'
  | 'health'
  | 'shopping'
  | 'other';

type Expense = {
  id: string;
  description: string;
  amount: number;
  category: Category;
  expense_date: string;
};

const categories: {
  value: Category;
  label: string;
  emoji: string;
}[] = [
  { value: 'food', label: 'Alimentação', emoji: '🍔' },
  { value: 'transport', label: 'Transporte', emoji: '🚗' },
  { value: 'education', label: 'Educação', emoji: '📚' },
  { value: 'leisure', label: 'Lazer', emoji: '🎮' },
  { value: 'health', label: 'Saúde', emoji: '❤️' },
  { value: 'shopping', label: 'Compras', emoji: '🛍️' },
  { value: 'other', label: 'Outros', emoji: '📦' },
];

export default function ExpensesScreen() {
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [category, setCategory] =
    useState<Category>('food');

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadExpenses();
  }, []);

  const totalExpenses = useMemo(() => {
    return expenses.reduce(
      (total, expense) => total + expense.amount,
      0
    );
  }, [expenses]);

  async function loadExpenses() {
    try {
      setLoading(true);

      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        router.replace('/login');
        return;
      }

      const { data, error } = await supabase
        .from('expenses')
        .select(
          'id, description, amount, category, expense_date'
        )
        .eq('student_id', user.id)
        .order('expense_date', {
          ascending: false,
        })
        .order('created_at', {
          ascending: false,
        });

      if (error) {
        console.error(error);

        Alert.alert(
          'Erro',
          'Não foi possível carregar seus gastos.'
        );

        return;
      }

      setExpenses(
        (data || []).map((expense) => ({
          ...expense,
          amount: Number(expense.amount),
        }))
      );
    } finally {
      setLoading(false);
    }
  }

  async function handleAddExpense() {
    if (!description.trim()) {
      Alert.alert(
        'Descrição obrigatória',
        'Digite uma descrição para o gasto.'
      );

      return;
    }

    const normalizedAmount = amount
      .replace(',', '.')
      .trim();

    const numericAmount = Number(normalizedAmount);

    if (!numericAmount || numericAmount <= 0) {
      Alert.alert(
        'Valor inválido',
        'Digite um valor maior que zero.'
      );

      return;
    }

    try {
      setSaving(true);

      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        router.replace('/login');
        return;
      }

      const { error } = await supabase
        .from('expenses')
        .insert({
          student_id: user.id,
          description: description.trim(),
          amount: numericAmount,
          category,
        });

      if (error) {
        console.error(error);

        Alert.alert(
          'Erro',
          'Não foi possível adicionar o gasto.'
        );

        return;
      }

      setDescription('');
      setAmount('');
      setCategory('food');

      await loadExpenses();
    } finally {
      setSaving(false);
    }
  }

  async function handleDeleteExpense(id: string) {
    const { error } = await supabase
      .from('expenses')
      .delete()
      .eq('id', id);

    if (error) {
      Alert.alert(
        'Erro',
        'Não foi possível excluir o gasto.'
      );

      return;
    }

    await loadExpenses();
  }

  function formatCurrency(value: number) {
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    });
  }

  function getCategoryInfo(category: Category) {
    return categories.find(
      (item) => item.value === category
    );
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
      <Pressable onPress={() => router.back()}>
        <Text style={styles.backButton}>
          ← Voltar
        </Text>
      </Pressable>

      <Text style={styles.title}>
        Controle de gastos
      </Text>

      <Text style={styles.subtitle}>
        Registre seus gastos e acompanhe para onde seu dinheiro está indo.
      </Text>

      <View style={styles.totalCard}>
        <Text style={styles.totalLabel}>
          Total registrado
        </Text>

        <Text style={styles.totalValue}>
          {formatCurrency(totalExpenses)}
        </Text>
      </View>

      <View style={styles.formCard}>
        <Text style={styles.sectionTitle}>
          Novo gasto
        </Text>

        <Text style={styles.label}>
          Descrição
        </Text>

        <TextInput
          style={styles.input}
          placeholder="Ex.: Lanche"
          placeholderTextColor="#9CA3AF"
          value={description}
          onChangeText={setDescription}
        />

        <Text style={styles.label}>
          Valor
        </Text>

        <TextInput
          style={styles.input}
          placeholder="Ex.: 25,00"
          placeholderTextColor="#9CA3AF"
          keyboardType="decimal-pad"
          value={amount}
          onChangeText={setAmount}
        />

        <Text style={styles.label}>
          Categoria
        </Text>

        <View style={styles.categories}>
          {categories.map((item) => {
            const selected =
              category === item.value;

            return (
              <Pressable
                key={item.value}
                style={[
                  styles.categoryButton,
                  selected &&
                    styles.categoryButtonSelected,
                ]}
                onPress={() =>
                  setCategory(item.value)
                }
              >
                <Text style={styles.categoryEmoji}>
                  {item.emoji}
                </Text>

                <Text
                  style={[
                    styles.categoryText,
                    selected &&
                      styles.categoryTextSelected,
                  ]}
                >
                  {item.label}
                </Text>
              </Pressable>
            );
          })}
        </View>

        <Pressable
          style={[
            styles.addButton,
            saving && styles.addButtonDisabled,
          ]}
          disabled={saving}
          onPress={handleAddExpense}
        >
          {saving ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.addButtonText}>
              Adicionar gasto
            </Text>
          )}
        </Pressable>
      </View>

      <View style={styles.expensesSection}>
        <Text style={styles.sectionTitle}>
          Seus gastos
        </Text>

        {expenses.length === 0 ? (
          <View style={styles.emptyCard}>
            <Text style={styles.emptyText}>
              Você ainda não registrou nenhum gasto.
            </Text>
          </View>
        ) : (
          expenses.map((expense) => {
            const categoryInfo =
              getCategoryInfo(expense.category);

            return (
              <View
                key={expense.id}
                style={styles.expenseCard}
              >
                <View style={styles.expenseIcon}>
                  <Text style={styles.expenseEmoji}>
                    {categoryInfo?.emoji || '📦'}
                  </Text>
                </View>

                <View style={styles.expenseInfo}>
                  <Text style={styles.expenseDescription}>
                    {expense.description}
                  </Text>

                  <Text style={styles.expenseCategory}>
                    {categoryInfo?.label || 'Outros'}
                  </Text>
                </View>

                <View style={styles.expenseRight}>
                  <Text style={styles.expenseAmount}>
                    {formatCurrency(expense.amount)}
                  </Text>

                  <Pressable
                    onPress={() =>
                      handleDeleteExpense(
                        expense.id
                      )
                    }
                  >
                    <Text style={styles.deleteText}>
                      Excluir
                    </Text>
                  </Pressable>
                </View>
              </View>
            );
          })
        )}
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
    paddingBottom: 50,
  },

  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F7FA',
  },

  backButton: {
    color: '#1B5E20',
    fontWeight: '600',
    fontSize: 16,
  },

  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1F2937',
    marginTop: 35,
  },

  subtitle: {
    color: '#6B7280',
    fontSize: 16,
    lineHeight: 24,
    marginTop: 10,
  },

  totalCard: {
    backgroundColor: '#1B5E20',
    borderRadius: 18,
    padding: 22,
    marginTop: 28,
  },

  totalLabel: {
    color: '#D1FAE5',
    fontSize: 14,
  },

  totalValue: {
    color: '#FFFFFF',
    fontSize: 30,
    fontWeight: 'bold',
    marginTop: 6,
  },

  formCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 18,
    padding: 20,
    marginTop: 24,
  },

  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 18,
  },

  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8,
  },

  input: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 14,
    fontSize: 16,
    color: '#111827',
    marginBottom: 18,
  },

  categories: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },

  categoryButton: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    paddingVertical: 10,
    paddingHorizontal: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },

  categoryButtonSelected: {
    borderColor: '#1B5E20',
    backgroundColor: '#E8F5E9',
  },

  categoryEmoji: {
    fontSize: 16,
    marginRight: 6,
  },

  categoryText: {
    color: '#4B5563',
    fontSize: 13,
    fontWeight: '500',
  },

  categoryTextSelected: {
    color: '#1B5E20',
    fontWeight: '700',
  },

  addButton: {
    backgroundColor: '#1B5E20',
    borderRadius: 12,
    alignItems: 'center',
    paddingVertical: 15,
    marginTop: 22,
  },

  addButtonDisabled: {
    opacity: 0.7,
  },

  addButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },

  expensesSection: {
    marginTop: 30,
  },

  emptyCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
  },

  emptyText: {
    color: '#6B7280',
  },

  expenseCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },

  expenseIcon: {
    width: 46,
    height: 46,
    borderRadius: 12,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
  },

  expenseEmoji: {
    fontSize: 22,
  },

  expenseInfo: {
    flex: 1,
    marginLeft: 12,
  },

  expenseDescription: {
    fontSize: 15,
    fontWeight: '700',
    color: '#1F2937',
  },

  expenseCategory: {
    fontSize: 13,
    color: '#6B7280',
    marginTop: 4,
  },

  expenseRight: {
    alignItems: 'flex-end',
  },

  expenseAmount: {
    fontSize: 15,
    fontWeight: 'bold',
    color: '#B91C1C',
  },

  deleteText: {
    color: '#9CA3AF',
    fontSize: 12,
    marginTop: 7,
  },
});