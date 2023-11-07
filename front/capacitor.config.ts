import { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.example.epichourly',
  appName: 'EpicHourly',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
  },
}

export default config
