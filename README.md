# ASFV-Data-Analysis
- 아프리카 돼지열병에 관한 빅데이터 분석
- ASFV : African Swine Fever Virus(아프리카 돼지열병 바이러스)

### Stacks & Skills
<img alt="R" src ="https://img.shields.io/badge/R-276DC3.svg?&style=for-the-badge&logo=R&logoColor=white"/><img alt="Twitter API" src ="https://img.shields.io/badge/Twitter API-1DA1F2.svg?&style=for-the-badge&logo=Twitter&logoColor=white"/>


### 목차
---
1. 분석 배경
2. 본인의 역할
3. 아프리카 돼지열병에 관한 워드 클라우드 및 감성 분석
4. 돼지고기 가격에 관한 감성 분석
5. 결론
6. 프로젝트 진행 후 느낀 점
7. 참고자료
---

### 1. 분석 배경
- 아프리카 돼지열병은 치료제나 백신이 없어 급성형인 경우에 치사율이 최대 100%에 이르는 전염병이다. 우리나라에선 2019년 9월 16일 경기도 파주시 소재 양돈농장을 시작으로 10월 9일까지 14개 농장에서 발생하였다. 아프리카 돼지열병 확산을 막기 위해 강도 높은 방역을 진행 중에 있다.
- 농림축산식품부에 의하면 기본적으로 아프리카 돼지열병에 감염된 돼지는 전량 살처분 및 매몰 처리되며, 이상이 있는 축산물의 경우 국내로 유통되지 않는 만큼 안심하고 돼지고기를 소비해도 된다고 하였다.
- 사람에게는 전염되지 않음에도 불구하고 아프리카 돼지열병 발생에 따른 돼지고기 소비 침체 및 가격 하락으로 양돈농가의 어려움이 가중되고 있다는 소식을 듣게 되었다. 이러한 소식을 듣고, 아프리카 돼지열병에 관한 생각과 아프리카 돼지열병으로 인한 돼지고기 소비에 대한 사람들의 생각이 어떤지 확인하기 위해 워드클라우드와 감성분석을 진행하기로 결정하였다.

### 2. 본인의 역할
- 프로젝트 기획
- 프로젝트에 필요한 데이터 수집, 데이터 전처리, 데이터 시각화 및 분석
- 프로젝트 분석 결과 정리

[R 코드 전문](https://github.com/yeonseoksong/ASFV_Data_Analysis/blob/main/code.R)

### 3. 아프리카 돼지열병에 관한 워드 클라우드 및 감성 분석

- 작업 디렉토리를 설정한 후, 이용할 패키지를 설치 및 실행시킨다.
  ```R
  install.packages("twitteR") # 트위터로 데이터 가지고 오기
  install.packages("KoNLP")
  install.packages("wordcloud")
  install.packages("stringr")
  install.packages("digest") # KoNLP 사용 위해 설치

  library(twitteR)
  library(stringr)
  library(KoNLP)
  library(wordcloud)
  
  # 작업 디렉토리 지정
  dir <- choose.dir()
  setwd(dir)
  ```
  
- (트위터 api에 대한 설명)
- 트위터 api 토큰을 인증받은 후, searchTwitter로 키워드를 검색 후 데이터를 수집한다. 한글은 따로 인코딩하여 UTF-8로 변환 시켜야 한다.
  ```R
  source("authenticate.R") # 토큰 인증

  # 인코딩
  keyword1 <- enc2utf8("돼지열병")

  # 키워드 : 돼지열병
  disease <- searchTwitter(keyword1, n = 3200, lang="ko") 
                                       # 돼지열병에 대해 표본 3200개를 한글로 뽑기

  df_disease <- do.call("rbind", lapply(disease, as.data.frame))
                                       # 돼지열병 데이터프레임

  # 데이터 저장
  write(df_disease$text, '돼지열병 검색어 데이터.txt')  
                                       # 돼지열병 데이터프레임 txt파일로 저장
  write(df_disease$text, '돼지열병 검색어 데이터.csv')  
                                       # 돼지열병 데이터프레임 csv파일로 저장
  ```
  
  ```R
  # authenticate.R은 개인 정보이므로, github에 첨부하지 않았다.
  # authenticate.R 양식
  api_key = "----authenticated-api-key----"
  api_secret = "-----authenticated-api-secret----"
  access_token = "----authenticated-access-token----"
  access_token_secret = "---authenticated-access-token-secret----"
  
  setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
  ```
  
- 데이터를 수집 후에 필요 없는 부분을 제거하기 위해 ```gsub()```와 ```extractNoun```을 이용하여 전처리 과정을 진행해야 한다.
  ```R
  # 전처리 과정
  disease.text <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", df_disease$text)  # 리트윗 제거  
  disease.text <- gsub("http\\w+", "", disease.text) # 링크 제거
  disease.text <- gsub("@[a-z]*", "", disease.text)  # @로 시작하는 영어소문자 0개 이상을 제거
  disease.text <- gsub("&[a-z]*", "", disease.text)  # &로 시작하는 영어소문자 0개 이상을 제거
  disease.text <- gsub("#[a-z]*", "", disease.text)  # #로 시작하는 영어소문자 0개 이상을 제거
  disease.text <- gsub("RT", "", disease.text)       # RT 제거

  useNIADic()  # 사전 불러오기

  # 전처리 과정
  dis_words <- sapply(disease.text, extractNoun, USE.NAMES=F)
  dis_words <- unlist(dis_words)
  dis_words <- gsub("[[:punct:]]", "", dis_words)                 # 구두점 지우기
  dis_words <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", dis_words) # 유니코드 제거
  dis_words <- gsub(keyword1, "", dis_words)                      # 키워드 지우기
  dis_words <- gsub("\\d+", "", dis_words)                        # 숫자 지우기
  dis_words <- gsub("[A-z]", "", dis_words)	                      # 모든 영문자 지우기
  dis_words <- gsub("▶*", "", dis_words)	                       # ▶로 시작되는 것들 지우기
  dis_words <- gsub("ð*", "", dis_words)	                        # ð로 시작되는 것들 지우기
  
  # 분석에 필요 없는 내용을 삭제하거나 비슷한 단어로 변환
  dis_words <- gsub("아프리카+|열병", "", dis_words)
  dis_words <- gsub("돼지", "", dis_words)
  dis_words <- gsub("가고|가능|가에", "", dis_words)
  dis_words <- gsub("감역", "감염", dis_words)
  dis_words <- gsub("강춘혁탈북래", "", dis_words)
  dis_words <- gsub("개더러웠음|개쓰레기", "개지랄", dis_words)
  dis_words <- gsub("거기", "", dis_words)
  dis_words <- gsub("갱기", "", dis_words)
  dis_words <- gsub("걸려뒈질|걸렸냐니|걸렸냐|걸린거", "걸렸나", dis_words)
  dis_words <- gsub("검색", "검역", dis_words)
  dis_words <- gsub("결과", "결국", dis_words)
  dis_words <- gsub("경기지사이해찬|경기지사·이해찬", "이해찬", dis_words)
  dis_words <- gsub("계엄령", "", dis_words)
  dis_words <- gsub("고생많으셨습니다", "고생", dis_words)
  dis_words <- gsub("관심을", "관심", dis_words)
  dis_words <- gsub("구닌들", "군인들", dis_words)
  dis_words <- gsub("국립", "국내", dis_words)
  dis_words <- gsub("군데", "군부대", dis_words)
  dis_words <- gsub("굿모닝|굿모닝하우스|굿모닝하우스나", "", dis_words)
  dis_words <- gsub("기레", "기레기", dis_words)
  dis_words <- gsub("기적이닷", "기적", dis_words)
  dis_words <- gsub("꼬락서니봐라|꼴값", "꼬라지", dis_words)
  dis_words <- gsub("꼴배", "", dis_words)
  dis_words <- gsub("난리났을때는", "난리", dis_words)
  dis_words <- gsub("났을때는경기도만", "경기도", dis_words)
  dis_words <- gsub("농가돕기|농림", "농가", dis_words)
  dis_words <- gsub("누구|니네|ㄷㅈㅇ|다하겠습니", "", dis_words)
  dis_words <- gsub("대국민", "국민", dis_words)
  dis_words <- gsub("더부", "더불어민주당", dis_words)
  dis_words <- gsub("동안|들이|마리", "", dis_words)
  dis_words <- gsub("못됬음|못한새끼야", "못됬고", dis_words)
  dis_words <- gsub("문푸정국이라|문푸정부가", "문푸정부", dis_words)
  dis_words <- gsub("뭐길래|뭐쩌라는거야|뭔지|뭘까|뭣때문에", "뭔데", dis_words)
  dis_words <- gsub("민원서비스", "민원", dis_words)
  dis_words <- gsub("발생지역", "발생", dis_words)
  dis_words <- gsub("부전프라임뉴스이재명", "이재명", dis_words)
  ```
  
- 그 후에 명사 중에서 두 글자 이상인 명사만 검색하도록 지정한 후, ```table()```함수를 이용하여 단어 빈도분석을 하고, ```sort()``` 함수를 사용하여 단어의 사용 빈도를 내림차순으로 정렬한다.
- 단어들이 많으므로, ```head()```를 이용하여 제일 많이 사용한 300개를 뽑아서 변수에 저장한다.
  ```R
  dis_words <- dis_words[nchar(dis_words) >= 2]
  dis_words_table <- table(dis_words)
  dis_words_table <- head(sort(dis_words_table, decreasing=T), 300)
  View(dis_words_table)
  ```
  
- 300개 중에서 제일 많이 사용하는 단어의 순위를 시각적으로 표시하기 위해 최다빈출 단어 15개에 대하여 빈도별 그래프를 그린다. 
- 빈도별 그래프를 저장한다.
  ```R
  # 최다 빈출되는 15개의 단어에 대한 빈도별 그래프 그리기

  dis_copy <- dis_words
  dis_copy <- table(dis_words)
  dis_copy <- head(sort(dis_copy, decreasing=T), 15)
  dis_copy <- as.data.frame(dis_copy)
  class(dis_copy$Freq)
  library(ggplot2)
  ggplot(dis_copy, aes(dis_copy$dis_words, dis_copy$Freq)) +
     ggtitle("최다 빈출 단어 빈도별 그래프") +
     theme(plot.title = element_text(colour = "blue", face = "bold", size = 20, hjust = 0.5))+
     labs(x = "단어", y = "빈도수") + 
     geom_bar(color = "black", fill = 'skyblue', stat = "identity") 

  # 빈도별 그래프 저장하기
  ggsave("bar graph.jpg", dpi = 300)
  ```

- 워드클라우드를 작성한다. 서울남산체를 다운받은 후, 서울남산체 M 폰트를 이용하였고, ```display.brewer.all()```에서 찾은 'Paired'색상을 사용하였다.
  ```R
  # 워드 클라우드 만들기
  display.brewer.all() # 색상 확인

  pair <- brewer.pal(5, "Paired")
  windowsFonts(namsan=windowsFont("서울남산체 M")) # 서울남산체 M으로 지정함.
  set.seed(1234)
  wordcloud(words = names(dis_words_table), freq=dis_words_table, scale=c(5, 0.5),
          colors = pair, min.freq=20, random.order=F,
                             family='namsan')

  # 워드클라우드2 만들기
  install.packages("wordcloud2")
  library(wordcloud2)
  dis_cloud = wordcloud2(dis_words_table, size = 1, backgroundColor = "white")
  dis_cloud
  
  # 워드클라우드2 저장
  install.packages("htmlwidgets")
  library(htmlwidgets)
  saveWidget(dis_cloud, "아프리카 돼지열병.html", selfcontained = F) # html파일로 저장
  ```
  
  - wordcloud 패키지를 이용한 워드 클라우드 결과
  ![image](https://user-images.githubusercontent.com/49339278/145690037-ebe437d2-2128-47fc-9aa7-d4f4253083f1.png)

  - wordcloud2 패키지를 이용한 워드 클라우드 결과
  ![image](https://user-images.githubusercontent.com/49339278/145690058-ca56f6b1-7fe3-45df-96a7-1b0f22756546.png)

### 4. 돼지고기 가격에 관한 감성 분석
- 이용할 패키지를 설치 및 실행시킨다. 그리고 감성분석할 때 트위터 api 인증을 받아야 하지만, 위에서 이미 인증 받았으므로 과정은 생략한다.
  ```R
  install.packages("plyr")
  
  library(twitteR)
  library(plyr)
  library(stringr)
  ```
  
- 문장에 대한 전처리 과정을 실시하고, 긍정사전과 부정사전을 매칭 시켜서 나온 감성점수를 반환하고, 각각의 문장과 점수를 데이터프레임으로 변환시키는 함수를 실행한다.
  ```R
  score.sentiment = function(sentences, pos.words, neg.words)
  {

     scores = laply(sentences, 
     function(sentence, pos.words, neg.words)
     {
        sentence = gsub("[[:punct:]]", "", sentence) # 문장부호 제거
        sentence = gsub("[[:cntrl:]]", "", sentence) # 특수문자 제거
        sentence = gsub('\\d+', '', sentence)	   # 숫자 제거

        word.list = strsplit(sentence, "\\s+")	   # 문장을 '빈칸'으로 나눔
                     # \\s+ : 빈칸 1칸 이상을 의미함.
        words = unlist(word.list)

        pos.matches = match(words, pos.words)	   # words의 단어를 positive에서 맞춘다.
        neg.matches = match(words, neg.words)	   # words의 단어를 negative에서 맞춘다.

        pos.matches = !is.na(pos.matches)		   # NA 제거함. 위치(숫자)만 추출함.
        neg.matches = !is.na(neg.matches)

        score = sum(pos.matches) - sum(neg.matches)  # score = 긍정점수 - 부정점수
        return(score)					   # score값 반환
      }, pos.words, neg.words)

     scores.df = data.frame(text=sentences, score=scores) # 각각의 문장과 점수를 데이터프레임으로 변환
     return(scores.df)
  } 					# 문장을 감성 점수를 측정하는 함수

  ```

- 군산대학교에서 만든 감성사전에 있는 긍정 사전과 부정 사전을 변수에 저장한다.
  ```R
  # 군산대에서 만든 감성사전에 있는 positive_KNU.txt와 negative_KNU.txt를 변수에 불러오기
  pos.words <- readLines("pos_pol_word.txt", encoding = "UTF-8")  # 긍정 사전
  neg.words <- readLines("neg_pol_word.txt", encoding = "UTF-8")  # 부정 사전
  ```
  
- 
### 5. 결론
### 6. 프로젝트 진행 후 느낀 점
### 7. 참고자료
