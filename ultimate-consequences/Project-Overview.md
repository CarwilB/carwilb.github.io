Ultimate Consequences Project Overview
================
Carwil Bjork-James
June 12, 2023

# Ultimate consequences: <br/> A comprehensive database of deaths in Bolivian political conflict during the democratic era, 1982–present

*This is an R Markdown document. Markdown is a simple formatting syntax
for authoring HTML, PDF, and MS Word documents. For more details on
using R Markdown see <http://rmarkdown.rstudio.com>.*

Mass grassroots politics in Bolivia has found highly contentious forms
of action that were nonetheless distinct from a conventional military
conflict. Its longer history, marked by indigenous uprisings, labor
militancy, and frequent military rule has been described in terms of
blood, fire, dynamite, and massacres. The social movement traditions
that have resulted include proclamations of fearlessness (even
protesting high schoolers shout, “Rifle, machine gun, we will not be
silenced!”) and vows to carry struggles “until the final consequences.”

The database enumerates individual deaths in Bolivian political conflict
since 1982, the end of military rule in the country. It is compiled by a
research team based on multiple sources, including media reports,
governmental, intergovernmental, and private human rights reports, and
use of the research literature on political conflict. The dataset now
includes nearly all of the deaths identified by a Permanent Assembly of
Human Rights-Bolivia (APDHB) study of deaths from 1988 to 2003, and a
study of the coca conflict from 1982 to 2005 (Navarro Miranda 2006;
Llorenti 2009; Salazar Ortuño 2008). Unlike prior compilations by human
rights organizations, however, this database includes a variety of
qualitative variables designed to understand how and why the deaths
occurred and what policies and patterns underpin them.

We designed the database to both catalog the lethal consequences of
participation in social movements and political activism, and to assess
responsibility, accountability, and impunity for violent deaths. All
deaths are significant as signs of the price that has been paid to seek
social change. Some deaths are also significant as elements of
repression or violence for which someone might ultimately be held
accountable. Rather than begin by asking, “Is this death someone’s
fault?,” we are coding each death according to multiple factors that
enable us to extract different subsets of the overall database for
different purposes. We estimate there were between 610 to 650 deaths
associated with Bolivian political conflict from October 1982 until
December 2019. As of June 2023, the project had identified **607** to
**626** of these deaths, Including the 24 more recent deaths, we have
identified **632** to **651** of a projected 654 deaths. The database
includes **616** named individuals.

The database is maintained as a Google Docs spreadsheet, which can be
queried by R scripts, and whose reports can be generated internally or
exported for further manual coding. (**Bold numbers** in this paragraph
are updated automatically using R scripts.)

Through this process, we have become familiar with reading multiple and
conflicting reports, evaluating official denials (we have created a data
column for such denials), collecting narrative accounts, coding what we
can based on the information, and signaling remaining questions. One
thing that we have learned through this process is that making informed
judgements, rather than marking all disputed facts with some kind of
asterisk, is absolutely foundational to being able to do comparative
work. The scale of the dataset for this period is both large enough to
identify significant patterns and small enough (unlike the situation in
some other Latin American countries) to permit the construction of a
database that includes detailed information about every death. Precisely
because its coverage is nearly comprehensive, the database offers a
systematic sample of cases for quantitative and/or qualitative analysis,
untainted by selection bias. We can say with near certainty that the
dataset includes all episodes of political conflict that caused three or
more deaths since 1982.

The dataset offers a grounded view on such questions as: What practices
and political choices result in some presidencies being far less violent
than others? What is the relative importance of different forms of
political violence, from repression of protest to guerrilla movements to
fratricidal disputes among movements? Which movements have succeeded
despite deadly repression? This database will serve as a new tool for
social scientists, oral historians, and human rights advocates to use in
answering these and other questions.

The situations described in the dataset principally involve the
following:

1.  Deaths from repression or confrontations with security forces during
    protest
2.  Deaths from security force incursions into politically active
    communities that are related to their activism
3.  Deaths from inter-movement and intra-movement confrontations
4.  Deaths of all kinds related to guerrilla or paramilitary activity
5.  Deaths of all kinds related to the conflict over coca growing
6.  Political assassinations of all kinds, including public officials,
    political activists, and journalists
7.  Deaths of social movement participants while in police custody for
    their activism
8.  Deaths from the hardships of protests and acts of self-sacrifice
    such as hunger strikes, long-distance marches etc.
9.  Acts of suicide as a form of protest
10. All deaths related to land conflicts that involve a
    collective/social movement organization on at least one side.

For each death, we record identifying information about the person who
died, the individual or group who caused the death, the place and time
of the death, the cause and circumstances of the death, whether the
death appears to be deliberate or intended, the geographic location, the
death’s connection to social movements and social movement campaigns,
sources of information available about the death, types of investigation
that have been performed, accountability processes, and relationship to
the Bolivian state. Analytical variables used so far include: political
assassination (a binary yes/no category); protest domain (aggregating
all protest campaigns into a small number of topics such as “labor” and
“municipal governance”); and denial (a binary yes/no category indicating
whether the perpetrator denied responsibility for the death). In
creating database entries, we create brief narrative descriptions of the
events involved and/or quote such descriptions directly from sources of
reporting. We also are collecting textual segments of reporting and
testimonial narrative relevant to each death.

## Which deaths are we recording

*Included, but excluded from summary calculations:* When aggregating
deaths for comparative purposes over time, we will exclude “non-conflict
accidents”: any unintended death that occurs through no deliberate
attempt to harm, and outside the context of open physical confrontation.
We anticipate that such deaths are unevenly recorded over time (i.e.,
more frequently noted in recent years) and have no particular bearing on
research questions we are exploring. We also exclude incidental deaths
(due to indirect effects of blockades, or

*Excluded, but recorded:* We are coding and maintaining in a parallel
list (currently an extra page in our spreadsheet) verifiable deaths that
appear to fall outside of our inclusion criteria (e.g., deaths from
criminal activity, deaths before the democratic period, apparently
apolitical deaths in police custody), and deaths during highly complex
events with great flux among sources (currently only the 2003 Gas War,
but we may add other events to this), when the death is only listed in a
single source without verifying details.

## Beyond the scope of the project

There are other politically charged forms of death in Bolivia including
*lynchings and capital punishment in community-based justice*;
*feminicide and gender-based homicide*; and *deaths emerging from
politically controversial policies or social failure*. We can expect
that prominent figures in social movements have been the victims of all
of these types of violence. Where that has occurred, we will record
their deaths separately from the main database and consider highlighting
them in our work, but not attempt quantitative comparisons around these
kinds of deaths.
