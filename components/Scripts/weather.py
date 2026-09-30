#!/usr/bin/env python3
import urllib.request, json, datetime, os

lat, lon, city = "40.2696", "22.5061", "Katerini, GR"

var_file = os.path.expanduser("~/.config/quickshell/components/Scripts/variables")
if os.path.exists(var_file):
    with open(var_file, "r") as f:
        for line in f:
            if "=" in line:
                key, val = line.strip().split("=", 1)
                val = val.strip('"').strip("'")
                if key == "LATITUDE": lat = val
                elif key == "LONGITUDE": lon = val
                elif key == "CITY": city = val

URL = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&hourly=temperature_2m,weather_code&timezone=auto&past_days=1&forecast_days=2"

try:
    req = urllib.request.Request(URL, headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'})
    
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        c = data['current']
        h = data['hourly']
        
        curr = f"{city}|{c['temperature_2m']}|{c['relative_humidity_2m']}|{c['apparent_temperature']}|{c['wind_speed_10m']}|{c['weather_code']}"
        
        current_hour_str = c['time'][:13] + ":00"
        
        try:
            current_idx = h['time'].index(current_hour_str)
        except ValueError:
            current_idx = 24 
            
        start_idx = current_idx - 3
        end_idx = current_idx + 4
        
        h_items = []
        for i in range(start_idx, end_idx):
            t = h['time'][i][-5:]
            h_items.append(f"{t},{h['temperature_2m'][i]},{h['weather_code'][i]}")
            
        print(f"{curr}||" + "|".join(h_items))
        
except Exception as e:
    print(f"Error|--|--|--|--|0||00:00,0,0|00:00,0,0|00:00,0,0|00:00,0,0|00:00,0,0|00:00,0,0|00:00,0,0")