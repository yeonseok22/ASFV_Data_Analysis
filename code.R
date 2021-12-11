install.packages("twitteR") # 트위터로 데이터 가지고 오기
install.packages("KoNLP")
install.packages("wordcloud")
install.packages("stringr")
install.packages("digest") # KoNLP 사용 위해 설치

library(twitteR)
library(stringr)
library(KoNLP)
library(wordcloud)

#setwd('C:/Users/XPS/Desktop/대학교 자료/공부/대학교/정보통계학과/3-2학기/빅데이터입문/기말과제') # 기존 작업 디렉토리

# 작업 디렉토리 지정
dir <- choose.dir()
setwd(dir)


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

# 
disease.text <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", df_disease$text)  
                                              # 리트윗 제거  
disease.text <- gsub("http\\w+", "", disease.text) # 링크 제거
disease.text <- gsub("@[a-z]*", "", disease.text) 
                                      # @로 시작하는 영어소문자 0개 이상을 제거
disease.text <- gsub("&[a-z]*", "", disease.text) 
                                      # &로 시작하는 영어소문자 0개 이상을 제거
disease.text <- gsub("#[a-z]*", "", disease.text) 
                                      # #로 시작하는 영어소문자 0개 이상을 제거
disease.text <- gsub("RT", "", disease.text)     # RT 제거


useNIADic()  # 사전 불러오기

# 전처리 과정
dis_words <- sapply(disease.text, extractNoun, USE.NAMES=F)
dis_words <- unlist(dis_words)
dis_words <- gsub("[[:punct:]]", "", dis_words)                # 구두점 지우기
dis_words <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", dis_words) # 유니코드 제거
dis_words <- gsub(keyword1, "", dis_words) # 키워드 지우기
dis_words <- gsub("\\d+", "", dis_words)    # 숫자 지우기
dis_words <- gsub("[A-z]", "", dis_words)	  # 모든 영문자 지우기
dis_words <- gsub("▶*", "", dis_words)	  # ▶로 시작되는 것들 지우기
dis_words <- gsub("ð*", "", dis_words)	  # ð로 시작되는 거들 지우기
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


dis_words <- dis_words[nchar(dis_words) >= 2]
dis_words_table <- table(dis_words)
dis_words_table <- head(sort(dis_words_table, decreasing=T), 300)
View(dis_words_table)


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
# 워드 클라우드 만들기
#display.brewer.all() # 색상 확인

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

# 감성분석하기

#library(twitteR)  # 앞에서 선언함
library(plyr)
library(stringr)

#source("authenticate.R") # 토큰 인증 # 앞에서 선언함

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

# 군산대에서 만든 감성사전에 있는 positive_KNU.txt와 negative_KNU.txt를 변수에 불러오기
pos.words <- readLines("pos_pol_word.txt", encoding = "UTF-8")  # 긍정 사전
neg.words <- readLines("neg_pol_word.txt", encoding = "UTF-8")  # 부정 사전



# 아까 분석했었던 트위터를 저장
disease_txt <- sapply(disease, function(x) x$getText(), USE.NAMES=F)
write.csv(disease_txt, "돼지열병 트위터 내용.txt")

disease.score <- score.sentiment(disease_txt, pos.words, neg.words)
table(disease.score$score)
View(disease.score)
mean(disease.score$score)

# qqplot 쓰기
library(ggplot2)
qplot(disease.score$score, xlab = "감성 점수", ylab = "개수")+ 
	geom_bar(color = 'black', fill = "skyblue")

# xlab, ylab으로 x축, y축 이름 정해줌
# 그래프는 테두리가 검은색인 파란색 히스토그램을 그렸다.

# qplot 저장하기
ggsave(file = "C:/Users/XPS/Desktop/대학교 자료/공부/대학교/정보통계학과/3-2학기/빅데이터입문/기말과제/bargraph2.jpg",
		width = 3.5, height = 5)


# 돼지고기 가격에 대하여 감성분석 실시하기
# rbind로 합친다.

word1 <- enc2utf8("돼지고기 가격")
word2 <- enc2utf8("삼겹살 가격")

price1 <- searchTwitter(word1, n = 500, lang="ko")
price2 <- searchTwitter(word2, n = 500, lang="ko")

df_price1 <- do.call("rbind", lapply(price1, as.data.frame))
df_price2 <- do.call("rbind", lapply(price2, as.data.frame))
price <- rbind(df_price1, df_price2)


# 데이터 저장
write.csv(price$text, "돼지고기 가격 검색어 데이터.txt")

# 감성분석 실시
price.score <- score.sentiment(price$text, pos.words, neg.words)


table(price.score$score)
mean(price.score$score)

# qqplot 쓰기
library(ggplot2)
qplot(price.score$score, xlab = "감성 점수", ylab = "개수")+ 
	geom_bar(color = 'black', fill = "skyblue")

# xlab, ylab으로 x축, y축 이름 정해줌
# 그래프는 테두리가 검은색인 파란색 히스토그램을 그렸다.

# qqplot 저장하기
ggsave(file = "C:/Users/XPS/Desktop/대학교 자료/공부/대학교/정보통계학과/3-2학기/빅데이터입문/기말과제/bargraph3.jpg",
		width = 3.5, height = 5)
