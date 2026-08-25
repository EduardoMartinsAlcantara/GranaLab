import { router } from 'expo-router';
import { useState } from 'react';
import {
    Pressable,
    StyleSheet,
    Text,
    View,
} from 'react-native';

type UserRole = 'student' | 'teacher';

export default function SelectRoleScreen() {
  const [selectedRole, setSelectedRole] =
    useState<UserRole | null>(null);

  function handleContinue() {
    if (!selectedRole) {
      return;
    }

    console.log(
      'Tipo de usuário escolhido:',
      selectedRole
    );
  }

  return (
    <View style={styles.container}>
      <Pressable onPress={() => router.back()}>
        <Text style={styles.backButton}>← Voltar</Text>
      </Pressable>

      <Text style={styles.title}>
        Como você vai usar o GranaLab?
      </Text>

      <Text style={styles.subtitle}>
        Escolha uma opção para personalizarmos sua experiência.
      </Text>

      <View style={styles.options}>
        <Pressable
          style={[
            styles.optionCard,
            selectedRole === 'student' &&
              styles.optionCardSelected,
          ]}
          onPress={() => setSelectedRole('student')}
        >
          <Text style={styles.emoji}>🎓</Text>

          <View style={styles.optionContent}>
            <Text style={styles.optionTitle}>
              Aluno
            </Text>

            <Text style={styles.optionDescription}>
              Quero aprender sobre educação financeira,
              controlar meus gastos e aprender sobre
              investimentos.
            </Text>
          </View>
        </Pressable>

        <Pressable
          style={[
            styles.optionCard,
            selectedRole === 'teacher' &&
              styles.optionCardSelected,
          ]}
          onPress={() => setSelectedRole('teacher')}
        >
          <Text style={styles.emoji}>👨‍🏫</Text>

          <View style={styles.optionContent}>
            <Text style={styles.optionTitle}>
              Professor
            </Text>

            <Text style={styles.optionDescription}>
              Quero criar turmas e acompanhar o progresso dos
              meus alunos.
            </Text>
          </View>
        </Pressable>
      </View>

      <Pressable
        style={[
          styles.continueButton,
          !selectedRole &&
            styles.continueButtonDisabled,
        ]}
        disabled={!selectedRole}
        onPress={handleContinue}
      >
        <Text style={styles.continueButtonText}>
          Continuar
        </Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },

  backButton: {
    fontSize: 16,
    color: '#1B5E20',
    fontWeight: '600',
  },

  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1F2937',
    lineHeight: 40,
    marginTop: 50,
  },

  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    lineHeight: 24,
    marginTop: 12,
  },

  options: {
    gap: 16,
    marginTop: 40,
  },

  optionCard: {
    backgroundColor: '#FFFFFF',
    borderWidth: 2,
    borderColor: '#E5E7EB',
    borderRadius: 16,
    padding: 20,
    flexDirection: 'row',
    alignItems: 'flex-start',
  },

  optionCardSelected: {
    borderColor: '#1B5E20',
    backgroundColor: '#E8F5E9',
  },

  emoji: {
    fontSize: 32,
    marginRight: 16,
  },

  optionContent: {
    flex: 1,
  },

  optionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1F2937',
  },

  optionDescription: {
    fontSize: 15,
    color: '#6B7280',
    lineHeight: 22,
    marginTop: 6,
  },

  continueButton: {
    backgroundColor: '#1B5E20',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 'auto',
  },

  continueButtonDisabled: {
    backgroundColor: '#A7C7A9',
  },

  continueButtonText: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: 'bold',
  },
});