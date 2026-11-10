import { NavigatorScreenParams } from '@react-navigation/native';

export type MainTabParamList = {
  Home: undefined;
  Schedule: undefined;
  Grades: undefined;
  Courses: undefined;
  More: undefined;
};

export type RootStackParamList = {
  Login: undefined;
  Main: NavigatorScreenParams<MainTabParamList>;
  Financial: undefined;
  Library: undefined;
  Notices: undefined;
  Support: undefined;
  Profile: undefined;
};

declare global {
  namespace ReactNavigation {
    // A augmentação do React Navigation exige uma interface vazia: ela existe
    // para herdar as rotas do app, não para declarar membros próprios.
    // eslint-disable-next-line @typescript-eslint/no-empty-object-type
    interface RootParamList extends RootStackParamList {}
  }
}
