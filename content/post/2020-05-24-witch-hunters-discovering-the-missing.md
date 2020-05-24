---
title: 'Witch hunters: discovering the missing'
author: Steph
date: '2020-05-24'
slug: witch-hunters-discovering-the-missing
categories: []
tags:
  - data analysis
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(fig.width=16, fig.height = 12) 

```

# Witch hunting in Europe: a discovery of missingness

_Data analysis isn't particularly technical, but in order to do it well - you need a full toolkit and understand how to use it. One thing we don't teach very expliticly is understanding missing data or the toolkit available to do so. That's what this post is about - it's not technical, it's not 'fancy', it's the down-in-the-weeds basics that applied work needs to be done well. That's it..!_

Recently, Leeson and and Russ [released a paper](http://www.peterleeson.com/Witch_Trials.pdf) describing the relationship between the witch trials of Europe and the competitiveness between the papal and reformation churches of medieval Europe. It's due to be released in [the Economic Journal](http://onlinelibrary.wiley.com/journal/10.1111/(ISSN)1468-0297) shortly.

The paper is a fascinating quantitative exploration: but the incredible achievement in data collection that under pins it shouldn't be overlooked. Leeson and Russ have developed a database of over 10 000 witch trials in middle ages Europe. [And they put it on Github for everyone](https://github.com/JakeRuss/witch-trials). 

I took a look at the dataset and thought that it provided a golden opportunity to do a little hunt of my own: and to show how some as-yet relatively unknown R packages can help with that.

One of our favourite books is _Good Omens_ by Terry Pratchet and Neil Gaiman. In it, Shadwell, intrepid witchfinder stalks across the countryside (or as far as his pensioner's ticket will take him) armed [with his witchfinder's kit](http://www.bbc.co.uk/programmes/p02fxsvg/p02k41dx). While we don't have the pendulum of righteousness, we've got the packages of visualisation and data discovery.

There are four packages I think are particularly useful for data exploration and visualisation: tidyverse, skimr, naniar and visdat.

```{r, eval = FALSE, echo = TRUE}
install.packages("naniar") # you only need to run these lines if you haven't installed the packages already
install.packages("skimr")
install.packages("visdat")
install.packages("tidyverse")
```

```{r, eval = TRUE, echo = TRUE, message = FALSE}
library(naniar) # you need to run these lines every time you use these packages
library(skimr)
library(tidyverse)
library(visdat)

```

# The witch trial data

The data is located in a number of different formats on Github, but here we'll use the `.csv` file that covers the trial data. We'll download it directly from Github.

```{r, eval = TRUE, echo = TRUE}
url <- "https://raw.githubusercontent.com/JakeRuss/witch-trials/master/data/trials.csv"

db <- read.csv(url)
```

The data is marvellously prepared and doesn't need anything in the way of cleaning for this project. I will however change the name of one of the variables we'll be using to make the process clearer. We'll call `gadm.adm0`, an administrative area `country` instead. This is a gross oversimplification of geography in the middle ages of Europe, but it describes the location of the trial in terms that wil be most familiar to many modern users.

```{r, eval = TRUE, echo = TRUE}
db$decade <- as.numeric(db$decade)
db$country <- db$gadm.adm0
db <- db[,-9]
```

# Data discovery: structure and content

[I talk alot about what I do with datasets when I first open them](http://rex-analytics.com/data-analysis-enough-with-the-questions-already/). Some of the specific R functions I find useful are:

```{r, eval = TRUE, echo = TRUE}
summary(db)
glimpse(db)
```

There's another recent addition which I think is fabulous for a quick look of what's in there, and that's from the `skimr` package.

```{r, eval = TRUE, echo = TRUE}
skim(db)
```

The contents of this database indicate dates of the trial - in years, decades or century, the number of tried persons, deaths and geographic information. But also a great deal of missing data, which is very common for the historic record.

If we wanted to know about the frequency of people accused and killed over time, we can work a little `dplyr` magic (this chart appears in similar form in the paper):

```{r, eval = TRUE, echo = TRUE}

bydecade <- db[,c(2,4,5)] %>% 
      group_by(decade) %>% 
      summarise(deathsDecade = sum(deaths, na.rm = TRUE), 
                triedDecade = sum(tried, na.rm = TRUE)) 

ggplot(bydecade, 
       aes(x = decade, y = deathsDecade))+ 
  xlab("Decade")+
  ylab("Deaths")+
  geom_line() + 
  theme_light()+
  theme(legend.position="bottom")+
  theme(
    axis.text.x=element_text(angle=45,hjust=1, size = 10))+
  ggtitle("Number of deaths over time")
```

Relatively low levels of deaths as a result of witch trials up until the mid-100s to the mid 1600s during which a massive spike occurred. Leeson and Russ discuss why they think that is.

This brings us to visualisation as a means of discovery: are there patterns in missingness?

# Patterns in data, patterns in the missing

Visualising data is incredibly important for understanding it, but without accounting for the missing it can be an incomplete picture. Enter `naniar` and `visdat`, two marvellously useful packages by Nick Tierney. _Congratulations Nick, you've just been dragooned into a witch hunt with me._

Both `naniar` and `visdat` provide augmentation to the `ggplot2` package to help visualise missing data. Let's take a look at the basics:

```{r, eval = TRUE, echo = TRUE}
vis_dat(db, palette = "cb_safe")+
  theme_light() 
```

Here I added `theme_light()` because that works best for my terrible eyesight and `palette = "cb_safe"` ensures that the chart can be read by someone with colour blindness. It's a simple tweak that ensures your visuals can be read by your audience. [I've let my coworkers down with this before](http://rex-analytics.com/data-visualisation-hex-codes-pantone-colours-accessibility/) and now it's something I'm habitual about.

We can see that there are large chunks of missing data here - latitude and longtitude are largely missing, the number of deaths in each trial is not always available, other geographical information is not always available.

Let's dig a little further using `visdat`. Here I'm using `vis_miss` and clustering on the proportion of missing data because I think it looks better (this adds some time and is optional), I also tweaked the axes and width to make it easier to read. Again, we can see geography as we get down to the more granular levels is missing - `gadm.adm2` and `gadm.adm1` are both location variables. On the other hand, the authors scrupulously recorded every source they used - this is _really_ useful if we wanted to filter by source for later work.

```{r, eval = TRUE, echo = TRUE}
vis_miss(db, cluster = TRUE, sort_miss = TRUE)+
  theme_light() +
  theme(legend.position="bottom")+
  theme(
    axis.text.x=element_text(angle=-45,hjust=1, size = 10))
```

Let's take a different look at where our missing variables are:
```{r, eval = TRUE, echo = TRUE}
gg_miss_var(db) + 
  theme_light()
```

# Building meaning from the missing

One of the really marvellous things about `naniar` in particular is building the presence of missing data into a visual analysis. 

Using `naniar` we can ask ourselves if it's possible missing data is a function of time: it doesn't appear to be.

```{r, eval = TRUE, echo = TRUE}
ggplot(db, 
       aes(x = decade, y = deaths))+ 
    xlab("Decade")+
    ylab("Deaths")+
    geom_miss_point() + 
    theme_light()+
    theme(legend.position="bottom")+
    theme(
    axis.text.x=element_text(angle=45,hjust=1, size = 10))+
    ggtitle("Number of deaths over time")

```

Or geography? Perhaps. 

```{r, eval = TRUE, echo = TRUE}
ggplot(db, 
       aes(x = country, y = deaths))+ 
  xlab("Country")+
  ylab("Deaths")+
  geom_miss_point() + 
  theme_light()+
  theme(legend.position="bottom")+
  theme(
  axis.text.x=element_text(angle=45,hjust=1, size = 10))+
  ggtitle("Number of deaths by country")

```

Many trials had more than one accused, how many died as a result of each trial? We know that 35% of the deaths data is missing. How might that play into that relationship?

```{r, eval = TRUE, echo = TRUE}
ggplot(db, 
       aes(x = tried, y = deaths)) + 
      xlab("People tried")+
      ylab("Deaths")+
      geom_miss_point() + 
      theme_light()+
      theme(legend.position="bottom")+
      theme(
      axis.text.x=element_text(angle=45,hjust=1, size = 10))+
      ggtitle("Number of trials compared to number of deaths")

```

If you're not familar with some of the minutiae of ggplot, here's the lowdown:

```{r, eval = FALSE, echo = TRUE}

ggplot(db, 
       aes(x = tried, y = deaths)) + # db = the data frame, aes() describes the aesthetic mapping
      xlab("People tried")+ # labels on x axis
      ylab("Deaths")+       # labels on y axis
      geom_miss_point() +   # the naniar layer giving missing values
      theme_light()+        # my personal theme preference
      theme(legend.position="bottom")+ 
                            # this puts the legend on the bottom instead of the side
      theme(
      axis.text.x=element_text(angle=45,hjust=1, size = 10))+ 
                            # I've changed the text angle (45 degrees), and the size (10pt) from the default
      ggtitle("Number of trials compared to number of deaths") 
                              # I added a title

```

That spectre of a 45 degree line is really a spectre: in a substantial proportion of trials, everybody accused died as a result. There is a cluster of trials of smaller numbers of people (as opposed to the mass trials of 100+ accused) where the accused were more commonly acquitted. The missing data is largely clustered around the lower numbers of accused. This makes sense: large trials were show-trials and Leeson and Russ' work clearly shows that witch trials _in general_ were intended for public consumption as a means of inter-church competition. It stands to reason that information about these extraordinary events was recorded and kept.

Now this one's _interesting_. If we look at the proportion of deaths out of those accused we can see two clear clusters that run the entire time period: in some trials everyone is acquitted, in others nobody is.

```{r, eval = TRUE, echo = TRUE, fig.width=16, fig.height = 22}

db <- mutate(db, pcntDeaths = deaths/tried)

ggplot(db, aes(x = decade, y = pcntDeaths, colour = country))+ 
  xlab("Decade")+
  ylab("% Deaths of those tried")+
  #geom_point() +
  geom_jitter()+
  theme_light()+
  geom_miss_point()+
  theme(legend.position="bottom")+
  facet_wrap(~country)+
  theme(
    axis.text.x=element_text(angle=45,hjust=1, size = 10))+
  ggtitle("% of deaths of those tried over time")

```

Trials that acquitted some but not others were relatively rare until the peak period between 1550-1650. We can also see that alot of those trials were in France, Germany, Switzerland and the UK: this is something of a frequency effect as they were two hotbeds for these trials. In countries like Italy, the Netherlands, Ireland and Spain, pretty much everyone got off or didn't, but trials were far fewer - this might be a facet of the different geopolitical realities for those countries as papal strongholds.


# Missing data, discovered

Russ and Leeson have achieved something incredible with their paper - and perhaps more importantly- their data. They've shown the geopolitical influences of a truly tragic period in European history and made that data available to the rest of us to keep exploring.

`Naniar` and `visdat` are two great tools to explore on deeper and more nuanced levels, no matter what dataset you're interrogating. Much more useful for discovering truth than [the bell, book and probably candle of Sergeant Shadwell](http://audiomens.tumblr.com/post/145230687727/bbcs-good-omens-radio-4-dramatisation-episode-3). 

Tools like `naniar` and `visdat` provide a great opportunity to interrogate your datasets on more detailed and nuanced levels and having them in your toolkit is well worth it!