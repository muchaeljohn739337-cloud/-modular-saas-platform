'use client';

import SidebarLayout from '@/components/SidebarLayout';
import WeatherSaaSDashboard from '@/components/WeatherSaaSDashboard';

export default function WeatherPage() {
  return (
    <SidebarLayout>
      <WeatherSaaSDashboard />
    </SidebarLayout>
  );
}
