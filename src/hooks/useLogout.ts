import { useCallback } from 'react';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/types';

type RootNavigation = NativeStackNavigationProp<RootStackParamList>;

/**
 * Encerra a sessão e devolve o app ao Login, descartando a pilha para que o
 * botão voltar não reabra as telas de quem saiu.
 *
 * Quando existir token de sessão, é aqui que ele será apagado — ter um lugar
 * só é justamente o motivo deste hook, já que o encerramento é oferecido em
 * duas telas.
 */
export function useLogout() {
  const navigation = useNavigation<RootNavigation>();

  return useCallback(() => {
    // O Perfil está direto na pilha raiz, mas a tela "Mais" está dentro das
    // abas: de lá, quem conhece a rota de Login é o navegador pai.
    const root = navigation.getParent<RootNavigation>() ?? navigation;
    root.reset({ index: 0, routes: [{ name: 'Login' }] });
  }, [navigation]);
}
