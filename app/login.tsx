import { router } from 'expo-router';
import { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { supabase } from '../lib/supabase';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleLogin() {
    if (!email.trim() || !password) {
      Alert.alert(
        'Campos incompletos',
        'Preencha seu e-mail e sua senha.'
      );

      return;
    }

    try {
      setLoading(true);

      const { data, error } =
        await supabase.auth.signInWithPassword({
          email: email.trim().toLowerCase(),
          password,
        });

      if (error) {
  console.log('Erro no login:', error.message);

  Alert.alert(
    'Não foi possível entrar',
    error.message
  );

  return;
}

      const user = data.user;

      if (!user) {
        Alert.alert(
          'Erro',
          'Não foi possível identificar o usuário.'
        );

        return;
      }

      const { data: profile, error: profileError } =
        await supabase
          .from('profiles')
          .select('name, role')
          .eq('id', user.id)
          .single();

      if (profileError || !profile) {
        console.error(profileError);

        Alert.alert(
          'Perfil não encontrado',
          'Não foi possível carregar seu perfil.'
        );

        return;
      }

      if (profile.role === 'student') {
        router.replace('/student-home');
        return;
      }

      if (profile.role === 'teacher') {
        router.replace('/teacher-home');
        return;
      }

      Alert.alert(
        'Perfil inválido',
        'O tipo de usuário não foi reconhecido.'
      );
    } catch (error) {
      console.error(error);

      Alert.alert(
        'Erro inesperado',
        'Não foi possível entrar. Tente novamente.'
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <Pressable
        onPress={() => router.back()}
        disabled={loading}
      >
        <Text style={styles.backButton}>← Voltar</Text>
      </Pressable>

      <Text style={styles.title}>Entrar</Text>

      <Text style={styles.subtitle}>
        Entre na sua conta para continuar aprendendo.
      </Text>

      <View style={styles.form}>
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

        <Pressable
          style={[
            styles.loginButton,
            loading && styles.loginButtonDisabled,
          ]}
          onPress={handleLogin}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.loginButtonText}>
              Entrar
            </Text>
          )}
        </Pressable>

        <Pressable
          onPress={() => router.push('/register')}
          disabled={loading}
        >
          <Text style={styles.registerText}>
            Ainda não tem conta? Criar conta
          </Text>
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
    paddingTop: 60,
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

  loginButton: {
    backgroundColor: '#1B5E20',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 10,
  },

  loginButtonDisabled: {
    opacity: 0.7,
  },

  loginButtonText: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: 'bold',
  },

  registerText: {
    textAlign: 'center',
    color: '#1B5E20',
    fontSize: 15,
    fontWeight: '600',
    marginTop: 24,
  },
});