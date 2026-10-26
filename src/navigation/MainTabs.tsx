import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Feather } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { fontFamily } from '../constants';
import { useColors } from '../theme';
import { HomeScreen } from '../screens/HomeScreen';
import { ScheduleScreen } from '../screens/ScheduleScreen';
import { GradesScreen } from '../screens/GradesScreen';
import { CoursesScreen } from '../screens/CoursesScreen';
import { MoreScreen } from '../screens/MoreScreen';
import { MainTabParamList } from './types';

const Tab = createBottomTabNavigator<MainTabParamList>();

const tabIcon: Record<keyof MainTabParamList, React.ComponentProps<typeof Feather>['name']> = {
  Home: 'home',
  Schedule: 'calendar',
  Grades: 'bar-chart-2',
  Courses: 'book',
  More: 'more-horizontal',
};

const tabLabel: Record<keyof MainTabParamList, string> = {
  Home: 'Início',
  Schedule: 'Horário',
  Grades: 'Notas',
  Courses: 'Cursos',
  More: 'Mais',
};

/** Navegação inferior das cinco telas primárias — equivalente à `.bottomnav` original. */
export function MainTabs() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: colors.violet,
        tabBarInactiveTintColor: colors.textFaint,
        tabBarLabelStyle: { fontFamily: fontFamily.monoBold, fontSize: 9.5 },
        tabBarStyle: {
          backgroundColor: colors.panel,
          borderTopColor: colors.line,
          borderTopWidth: 1,
          // A lib só soma o inset quando não damos altura própria (ver
          // `getTabBarHeight`), e nosso `paddingBottom` sobrescreve o dela —
          // então os dois precisam do inset somado aqui.
          height: 76 + insets.bottom,
          paddingTop: 8,
          paddingBottom: 12 + insets.bottom,
        },
        tabBarIcon: ({ color, size }) => (
          <Feather name={tabIcon[route.name as keyof MainTabParamList]} size={size - 2} color={color} />
        ),
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} options={{ tabBarLabel: tabLabel.Home }} />
      <Tab.Screen name="Schedule" component={ScheduleScreen} options={{ tabBarLabel: tabLabel.Schedule }} />
      <Tab.Screen name="Grades" component={GradesScreen} options={{ tabBarLabel: tabLabel.Grades }} />
      <Tab.Screen name="Courses" component={CoursesScreen} options={{ tabBarLabel: tabLabel.Courses }} />
      <Tab.Screen name="More" component={MoreScreen} options={{ tabBarLabel: tabLabel.More }} />
    </Tab.Navigator>
  );
}
