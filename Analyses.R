library(readr)
library(ggplot2)
library(tidyverse)
library(usmap)
library(lme4)
library(reshape2)
library(svglite)
library(ez)

datadir <- '//wsl.localhost/Ubuntu/home/sean/2016_election/data/'
filelist <- c('debate1-1.json.tsv', 'debate1-2.json.tsv', 'debate1-3.json.tsv', 'debate1-4.json.tsv', 'debate2-1.json.tsv', 'debate2-2.json.tsv', 'debate2-3.json.tsv', 'debate3-1.json.tsv', 'debate3-2.json.tsv', 'debate3-3.json.tsv', 'election1.json.tsv', 'election2.json.tsv', 'election3.json.tsv', 'election4.json.tsv')

df <- data.frame()

for (file in filelist) {
  df_temp <- read_delim(paste0(datadir, file), delim = "\t", escape_double = FALSE, trim_ws = TRUE)
  if (grepl("debate", file) == TRUE) {
    event <- substr(file, 7, 7)
  }
  else {
    event <- 4
  }
  df_temp$event <- event
  df <- rbind(df, df_temp)
}

rm(df_temp)
gc()

colnames(df)[colnames(df) == "ids[i]"] <- "ID"

df$normalized_state <- sapply(df$location, extract_state)

trump_states <- c('ID','UT','AZ','MT','WY','ND','SD','NE','KS','OK','TX','IA','IA','MO','AR','LA','WI','MI','IN','OH','PA',
                  'WV','KY','TN','MS','AL','GA','FL','SC','NC')

all_states <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")

df$trump_state <- ifelse(!is.na(df$normalized_state) & df$normalized_state %in% trump_states, 1,
                         ifelse(!is.na(df$normalized_state) & !(df$normalized_state %in% trump_states), 0, NA))


long_df <- melt(df, id.vars = c("event", "normalized_state"), measure.vars = "sexist")
wide_df <- dcast(long_df, event + normalized_state ~ variable, fun.aggregate = sum)

wide_df$total_tweets <- table(df$event, df$normalized_state)[cbind(wide_df$event, wide_df$normalized_state)]

wide_df$perc_sexist <- (wide_df$sexist/wide_df$total_tweets) * 100

wide_df$trump_win <- 0

for (state in all_states) {
  if (state %in% trump_states) wide_df$trump_win[wide_df$normalized_state==state] <- 1
}

wide_df <- na.omit(wide_df)

model <- glmer(trump_win ~ perc_sexist + (1 | event) +
                 (1 | normalized_state), 
               data = wide_df, 
               family = binomial)
summary(model)

df_states <- dcast(wide_df, normalized_state ~ ., value.var = "perc_sexist", fun.aggregate = mean)
colnames(df_states) <- c("state", "perc_sexist")

df_election_results$perc_trump <- (df_election_results$POP_TRUMP/df_election_results$POP_TOTAL) * 100
names(df_election_results)[1] <- 'state'
df_election_results$normalized_state <- df_election_results$state
wide_df <- merge(wide_df, df_election_results[, c("perc_trump", "normalized_state")], by = "normalized_state")

map <- plot_usmap(
  color = "black", linewidth = 0.2,  data = df_states, values = "perc_sexist") +
  scale_fill_gradient(high = 'red', low = 'white') +
  theme(legend.position = "none")
ggsave("us_map_sexism.svg", plot = map, width = 10, height = 7, dpi = 300)

map <- plot_usmap(
  color = "black", linewidth = 0.2,  data = df_election_results, values = "perc_trump") +
  scale_fill_gradient(high = 'red', low = 'white') +
  theme(legend.position = "none")
ggsave("us_map_election.svg", plot = map, width = 10, height = 7, dpi = 300)

df_events <- dcast(long_df, event ~ ., value.var = "value", fun.aggregate = function(x) mean(x, na.rm = TRUE))
colnames(df_events)[colnames(df_events) == "."] <- "perc_sexist"
df_events$perc_sexist <- df_events$perc_sexist * 100

model <- lmer(perc_trump ~ perc_sexist + (1 | event) + (1 | normalized_state),
              data = wide_df)
summary(model)

cor.test(wide_df$perc_trump, wide_df$perc_sexist)



sexism_time_plot <- ggplot(wide_df, aes(x = event, y = perc_sexist, group = 1)) +
  geom_boxplot(aes(group = event), alpha = 0.3, fill = "blue", outlier.shape = NA) +
  geom_point(size = 1, color = "black", alpha = .1) +
  labs(
    title = "Sexist Tweets Over Time",
    x = "Event",
    y = "% Tweets Labeled Sexist"
  ) +
  theme(axis.text.x = element_text(angle=0), plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(name ="\nEvent", labels=c("Debate 1\n(9/26)", "Debate 2\n(10/9)", "Debate 3\n(10/19)", "Election Night\n(11/8)"))
ggsave("us_time_election.svg", plot = sexism_time_plot, width = 6, height = 4, dpi = 300)


anova_results <- ezANOVA(
  data = wide_df,
  dv = perc_sexist,  # Dependent variable
  wid = normalized_state,           # Within-subjects variable (user ID)
  within = event,          # Repeated-measures factor
  detailed = TRUE
)
summary(anova_results)
anova_results

model <- glmer(sexist ~ event + (1 | ID), 
               data = df, 
               family = binomial)
