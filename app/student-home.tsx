import { StyleSheet, Text, View } from 'react-native';

export default function StudentHomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Área do Aluno</Text>

      <Text style={styles.subtitle}>
        Login realizado com sucesso.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },

  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1B5E20',
  },

  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    marginTop: 12,
  },
});