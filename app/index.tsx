import { router } from 'expo-router';
import { Pressable, StyleSheet, Text, View } from 'react-native';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.logo}>GranaLab</Text>

        <Text style={styles.title}>
          Educação financeira de um jeito simples.
        </Text>

        <Text style={styles.description}>
          Aprenda a organizar seus gastos, complete atividades e use dinheiro
          fictício para aprender sobre investimentos.
        </Text>
      </View>

      <View style={styles.buttons}>
        <Pressable
          style={styles.primaryButton}
          onPress={() => router.push('/login')}
        >
          <Text style={styles.primaryButtonText}>Entrar</Text>
        </Pressable>

        <Pressable
          style={styles.secondaryButton}
          onPress={() => router.push('/register')}
        >
          <Text style={styles.secondaryButtonText}>Criar conta</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
    paddingHorizontal: 24,
    paddingTop: 80,
    paddingBottom: 40,
    justifyContent: 'space-between',
  },

  content: {
    marginTop: 70,
  },

  logo: {
    fontSize: 42,
    fontWeight: 'bold',
    color: '#1B5E20',
    marginBottom: 30,
  },

  title: {
    fontSize: 30,
    fontWeight: 'bold',
    color: '#1F2937',
    lineHeight: 38,
  },

  description: {
    fontSize: 17,
    color: '#6B7280',
    lineHeight: 26,
    marginTop: 18,
  },

  buttons: {
    gap: 14,
  },

  primaryButton: {
    backgroundColor: '#1B5E20',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
  },

  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: 'bold',
  },

  secondaryButton: {
    borderWidth: 2,
    borderColor: '#1B5E20',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
  },

  secondaryButtonText: {
    color: '#1B5E20',
    fontSize: 17,
    fontWeight: 'bold',
  },
});