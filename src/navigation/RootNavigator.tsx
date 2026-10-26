import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useColors } from '../theme';
import { LoginScreen } from '../screens/LoginScreen';
import { FinancialScreen } from '../screens/FinancialScreen';
import { LibraryScreen } from '../screens/LibraryScreen';
import { NoticesScreen } from '../screens/NoticesScreen';
import { SupportScreen } from '../screens/SupportScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { MainTabs } from './MainTabs';
import { RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();

/**
 * Pilha raiz da navegação: porta de login e, sobre as abas principais,
 * as telas secundárias (Financeiro, Biblioteca, Avisos, Suporte, Perfil),
 * cada uma com seu próprio `TopBar` fazendo o papel do botão "voltar".
 */
export function RootNavigator() {
  const colors = useColors();
  return (
    <Stack.Navigator
      initialRouteName="Login"
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.void },
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Main" component={MainTabs} />
      <Stack.Screen name="Financial" component={FinancialScreen} />
      <Stack.Screen name="Library" component={LibraryScreen} />
      <Stack.Screen name="Notices" component={NoticesScreen} />
      <Stack.Screen name="Support" component={SupportScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  );
}
