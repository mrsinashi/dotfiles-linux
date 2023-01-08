#!/bin/bash

case "$1" in
    --minsk)
        region="minsk-4248"
        mark="Minsk:"
        ;;
    *)
        region="irkutsk-4787"
        mark="Irk:"
        ;;
esac

json_data=$(echo {$(curl --http1.1 https://www.gismeteo.ru/weather-$region/now/ -H "User-Agent:Chrome" 2> /dev/null | grep "M.state.weather.cw" | sed 's|.*{||g; s|}.*||g')})

if [[ json_data == "" ]] || [[ json_data == "null" ]]
then
    echo ""
    exit
fi

temperature=$(echo $json_data | jq ".temperatureAir[]") 2> /dev/null

if [[ temperature == "" ]]
then
    echo ""
    exit
fi

sed_temperature=$(echo $temperature | sed 's|\..*||g')
weather_icon=$(echo $json_data | jq ".iconWeather[]" | tr -d \")
wind_speed=$(echo $json_data | jq ".windSpeed[]")

yellow="%{F#DEC868}"
blue="%{F#6D87EE}"
red="%{F#DC415E}"
white="%{F-}"

parse_icon() {
    dn=$(echo $weather_icon | sed 's|_.*||g')
    cloud=$(echo $weather_icon | grep _c | sed 's|.*_c||g;s|_.*||g;')
    rainsnow=$(echo $weather_icon | grep _rs | sed 's|.*_rs||g;s|_.*||g;')
    rain=$(echo $weather_icon | grep _r | sed 's|.*_r||g;s|_.*||g;')
    snow=$(echo $weather_icon | sed 's|st.*||g' | grep _s | sed 's|.*_s||g;s|_.*||g;')
    storm=$(echo $weather_icon | grep _st)

    grep_null=$(echo 1 | grep 2)

    if [[ $cloud == "" ]]
    then
        if [[ $dn == "d" ]]
        then
            dn_icon="${yellow}O${white}"
        else
            dn_icon="${blue}P${white}"
        fi
    else
        if ! [[ $cloud == "1" ]]
        then
            dn_icon="${blue}U${white}"
        elif [[ $dn == "d" ]]
        then
            dn_icon="${yellow}Q${white}"
        else
            dn_icon="${blue}R${white}"
        fi
    fi

    if ! [[ $rainsnow == "" ]]
    then
        if [[ $rainsnow == "1" ]]
        then
            downfall_icon="%{T7}S T%{T-}"
        elif [[ $rainsnow == "2" ]]
        then
            downfall_icon="${blue}%{T7}S T%{T-}${white}"
            bold="${blue}%{T8}"
        elif [[ $rainsnow == "3" ]]
        then
            downfall_icon="${red}%{T7}S T%{T-}${white}"
            bold="${red}%{T8}"
        fi
        space=" "
    elif ! [[ $rain == "" ]]
    then
        if [[ $rain == "1" ]]
        then
            downfall_icon="%{T7}S%{T-}"
        elif [[ $rain == "2" ]]
        then
            downfall_icon="${blue}%{T7}S%{T-}${white}"
            bold="${blue}%{T8}"
        elif [[ $rain == "3" ]]
        then
            downfall_icon="${red}%{T7}S%{T-}${white}"
            bold="${red}%{T8}"
        fi
        space=" "
    elif ! [[ $snow == "" ]]
    then
        if [[ $snow == "1" ]]
        then
            downfall_icon="%{T7}T%{T-}"
        elif [[ $snow == "2" ]]
        then
            downfall_icon="${blue}%{T7}T%{T-}${white}"
            bold="${blue}%{T8}"
        elif [[ $snow == "3" ]]
        then
            downfall_icon="${red}%{T7}T%{T-}${white}"
            bold="${red}%{T8}"
        fi
        space=" "
    else
        downfall_icon=""
        space=""
    fi

    if [ $wind_speed -ge 8 ]
    then
        wind_icon=" %{T8}${red}[ %{T7}W%{T8} $wind_speed m/s ]${white}%{T7}"
    elif [ $wind_speed -ge 6 ]
    then
        wind_icon=" %{T8}${blue}[ %{T7}W%{T8} $wind_speed m/s ]${white}%{T7}"
    elif [ $wind_speed -ge 4 ]
    then
        wind_icon=" %{T-}[ %{T7}W%{T-} $wind_speed m/s ]%{T7}"
        
    fi

    if ! [[ $storm == $grep_null ]]
    then
        downfall_icon="$downfall_icon$space%{T7}${red}V%{T-}${white}"
        bold="${red}%{T8}"
    fi

    if ! [[ $downfall_icon == "" ]]
    then
        downfall_icon="%{T-}  $bold[${white} $downfall_icon $bold]${white}%{T-}"
    fi
}

color_temperature() {
    if [ $sed_temperature -le "-21" ] || [ $sed_temperature -ge "27" ]
    then
        temperature="%{T8}${red}[ $temperature° ]${white}%{T-}"
    elif [ $sed_temperature -ge "-11" ] && [ $sed_temperature -le "11" ]
    then
        temperature="[ $temperature° ]"
    elif [ $sed_temperature -gt "-21" ] && [ $sed_temperature -lt "-11" ]
    then
        temperature="%{T8}${blue}[ $temperature° ]${white}%{T-}"
    else
        temperature="%{T8}${yellow}[ $temperature° ]${white}%{T-}"
    fi
}

parse_icon
color_temperature

echo "%{F#888F9B}$mark %{F-}%{T7}$dn_icon$downfall_icon$wind_icon%{T-} $temperature"