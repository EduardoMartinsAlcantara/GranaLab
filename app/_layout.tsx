import { Stack } from 'expo-router';

import { RegisterProvider } from '../contexts/RegisterContext';

export default function RootLayout() {
  return (
    <RegisterProvider>
      <Stack
        screenOptions={{
          headerShown: false,
        }}
      />
    </RegisterProvider>
  );
}