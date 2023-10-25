#! /bin/bash
# author : ParkChanJun
# date : 2023.10.23~2023.10.25

item=$1 #movie data
data=$2 #movie+id connect
user=$3 #user data

function One_function {
    while true
    do
        read -p "Please enter 'movie id'(1~1682): " findId
        if [ $findId -ge 1 ] && [ $findId -le $(cat $item | wc -l) ]
        then
            break
        fi
    done
    # cat $item | sed -n "$findId p"  # version1
    echo
    cat $item | awk -v findId=$findId -F '|' '{if($1 == findId) print}'
    echo
}

function Two_function {
    while true
    do
        read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n): " allowYN
        if [ "$allowYN" = "y" ] || [ "$allowYN" = "n" ]
        then
            break
        fi
    done
    if [ $allowYN == "y" ] 
    then
        echo
        cat $item | awk -F '|' '{if($7 == 1) printf("%s %s\n", $1, $2)}' | head -n 10
        echo
    fi
}

function Three_function {
    while true
    do
        read -p "Please enter the 'movie id'(1~1682): " findId
        if [ $findId -ge 1 ] && [ $findId -le $(cat $item | wc -l) ]
        then
            break
        fi
    done
    
    echo
    echo -n "average rating of $findId: "

    #Total=0
    #cnt=0
    #for i in $(cat $data | awk -v findId="$findId" '{if($2 == findId) print $3}')
    #do
    #    cnt=$((cnt+1))
    #    Total=$((Total+$i))
    #done

    Total=$(cat $data | awk -v findId="$findId" '{if($2 == findId) sum+=$3} END {print sum}')
    cnt=$(cat $data | awk -v findId="$findId" '{if($2 == findId) print $3}' | wc -l)
    
    if [ $cnt == 0 ]
    then
        echo "No ratings"
    else
        echo $(printf "%.5f" $(echo "scale=6; $Total / $cnt" | bc))
    fi
    echo
}

function Four_function {
    while true
    do
        read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n): " allowYN
        if [ "$allowYN" = "y" ] || [ "$allowYN" = "n" ]
        then
            break
        fi
    done
    if [ $allowYN == "y" ] 
    then
        echo
        cat $item | sed -E 's/http:\/\/us.imdb.com[^|]*//g' | head -n 10
        echo
    fi
}

function Five_function {
    while true
    do
        read -p "Do you want to get the data about users from 'u.user'?(y/n): " allowYN
        if [ "$allowYN" = "y" ] || [ "$allowYN" = "n" ]
        then
            break
        fi
    done
    if [ $allowYN == "y" ] 
    then
        echo
        cat $user | awk -F '|' '{printf("user %s is %s years old ", $1, $2); if($3=="M") printf("male %s\n", $4); else printf("female %s\n", $4)}' | head -n 10
        echo
    fi
}

function Six_funtion {
    while true
    do
        read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n): " allowYN
        if [ "$allowYN" = "y" ] || [ "$allowYN" = "n" ]
        then
            break
        fi
    done
    if [ $allowYN == "y" ] 
    then
        echo

        IFS=$'\n'
        for movie in $(cat $item | tail -n 10)
        do
            dateFormat=$(date -d "$(echo $movie | cut -d\| -f3 | head -n 1)" +%Y%m%d)
            echo $movie | sed -E "s/([^|]*\|[^|]*\|)[0-9]{2}-[A-Za-z]{3}-[0-9]{4}/\1$dateFormat/g"
        done

        echo
    fi
}

function Seven_function {
    while true
    do
        read -p "Please enter the 'user id'(1~943): " findUserId
        if [ $findUserId -ge 1 ] && [ $findUserId -le $(cat $user | wc -l) ]
        then
            break
        fi
    done
    
    echo
    movieSet=$(cat $data | awk -v findId="$findUserId" '{if($1 == findId) print $2}' | sort -n | sed -z -E 's/\n/|/g')
    echo ${movieSet:0:-1}   # delete last bar
    echo

    IFS=$'|'
    for i in $movieSet
    do
        cat $item | awk -v i="$i" -F '|' '{if($1 == i) printf("%s|%s\n", i, $2)}'
    done
    echo
    IFS=$'\n'
}

function Eight_function {
    while true
    do
        read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): " allowYN
        if [ "$allowYN" = "y" ] || [ "$allowYN" = "n" ]
        then
            break
        fi
    done
    if [ $allowYN == "y" ] 
    then
        prog20To29s=""
        for userId in $(cat $user | awk -v occupation="programmer" -F '|' '{if($4 == occupation && $2 < 30 && $2 >= 20) print $1}')
        do
            for movieIdWithRating in $(cat $data | awk -v userId="$userId" '{if($1 == userId) printf("%s,%s\n", $2, $3)}')
            do
                prog20To29s+=${movieIdWithRating}$'\n'
            done
        done
        
        movieId=0
        while true
        do
            movieId=$(($movieId+1))
            if [ $movieId -gt $(cat $item | wc -l) ] # $(cat $item | wc -l)
            then
                break
            fi

            # Total=0
            # cnt=0
            
            # for i in $(echo "$prog20To29s" | awk -v movieId="$movieId" -F ',' '{if($1 == movieId) print $2}')
            # do
            #     cnt=$((cnt+1))
            #     Total=$((Total+$i))
            # done

            Total=$(echo "$prog20To29s" | awk -v movieId="$movieId" -F ',' '{if($1 == movieId) sum+=$2} END {print sum}')
            cnt=$(echo "$prog20To29s" | awk -v movieId="$movieId" -F ',' '{if($1 == movieId) print $2}' | wc -l)

            if [ $cnt != 0 ]
            then
                echo -n "$movieId "
                echo $(printf "%.5f" $(echo "scale=6; $Total / $cnt" | bc)) | sed -e 's/[0]*$//g' | sed -e 's/\.$//g'
            fi
        done

        echo
    fi
}   

echo "--------------------------"
echo "User Name: ParkChanJun"
echo "Student Number: 12181613"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true
do
    read -p "Enter your choice [ 1-9 ] " choice
    echo

    case $choice in
    1)
    One_function;;
    2)
    Two_function;;
    3)
    Three_function;;
    4)
    Four_function;;
    5)
    Five_function;;
    6)
    Six_funtion;;
    7)
    Seven_function;;
    8)
    Eight_function;;
    9)
    echo "Bye!";;
    esac

    if [ $choice == 9 ]
    then
        break
    fi
done