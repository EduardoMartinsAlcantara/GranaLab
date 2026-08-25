import { router } from 'expo-router';
import { useState } from 'react';
import {
  Alert,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { useRegister } from '../contexts/RegisterContext';

export default function RegisterScreen() {
  const { setRegisterData } = useRegister();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  function handleContinue() {
    if (
      !name.trim() ||
      !email.trim() ||
      !password ||
      !confirmPassword
    ) {
      Alert.alert(
        'Campos incompletos',
        'Preencha todos os campos.'
      );

      return;
    }

    if (!email.includes('@') || !email.includes('.')) {
      Alert.alert(
        'E-mail inválido',
        'Digite um endereço de e-mail válido.'
      );

      return;
    }

    if (password.length < 6) {
      Alert.alert(
        'Senha muito curta',
        'Sua senha precisa ter pelo menos 6 caracteres.'
      );

      return;
    }

    if (password !== confirmPassword) {
      Alert.alert(
        'Senhas diferentes',
        'As duas senhas precisam ser iguais.'
      );

      return;
    }

    setRegisterData({
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password,
    });

    router.push('/select-role');
  }

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      keyboardShouldPersistTaps="handled"
    >
      <Pressable onPress={() => router.back()}>
        <Text style={styles.backButton}>← Voltar</Text>
      </Pressable>

      <Text style={styles.title}>Criar conta</Text>

      <Text style={styles.subtitle}>
        Crie sua conta para começar sua jornada financeira.
      </Text>

      <View style={styles.form}>
        <Text style={styles.label}>Nome</Text>

        <TextInput
          style={styles.input}
          placeholder="Digite seu nome"
          placeholderTextColor="#9CA3AF"
          value={name}
          onChangeText={setName}
        />

        <Text style={styles.label}>E-mail</Text>

        <TextInput
          style={styles.input}
          placeholder="seuemail@exemplo.com"
          placeholderTextColor="#9CA3AF"
          keyboardType="email-address"
          autoCapitalize="none"
          value={email}
          onChangeText={setEmail}
        />

        <Text style={styles.label}>Senha</Text>

        <TextInput
          style={styles.input}
          placeholder="Digite sua senha"
          placeholderTextColor="#9CA3AF"
          secureTextEntry
          value={password}
          onChangeText={setPassword}
        />

        <Text style={styles.label}>Confirmar senha</Text>

        <TextInput
          style={styles.input}
          placeholder="Digite sua senha novamente"
          placeholderTextColor="#9CA3AF"
          secureTextEntry
          value={confirmPassword}
          onChangeText={setConfirmPassword}
        />

        <Pressable
          style={styles.registerButton}
          onPress={handleContinue}
        >
          <Text style={styles.registerButtonText}>
            Continuar
          </Text>
        </Pressable>

        <Pressable onPress={() => router.push('/login')}>
          <Text style={styles.loginText}>
            Já possui uma conta? Entrar
          </Text>
        </Pressable>
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

  backButton: {
    fontSize: 16,
    color: '#1B5E20',
    fontWeight: '600',
  },

  title: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#1F2937',
    marginTop: 50,
  },

  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    lineHeight: 24,
    marginTop: 10,
  },

  form: {
    marginTop: 40,
  },

  label: {
    fontSize: 15,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8,
  },

  input: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 15,
    fontSize: 16,
    marginBottom: 20,
    color: '#111827',
  },

  registerButton: {
    backgroundColor: '#1B5E20',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 10,
  },

  registerButtonText: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: 'bold',
  },

  loginText: {
    textAlign: 'center',
    color: '#1B5E20',
    fontSize: 15,
    fontWeight: '600',
    marginTop: 24,
  },
});