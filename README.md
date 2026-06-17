# Data Linkage Techniques

Understanding and applying deterministic, fuzzy, and probabilistic methods to link records across datasets.

---

## Overview

This talk provides an introduction to **data linkage techniques** used to identify and connect records that refer to the same individual, organization, or entity across multiple datasets. We cover common linkage approaches, including **deterministic matching**, **fuzzy matching**, and **probabilistic linkage**, along with practical considerations for data cleaning, evaluation, and quality assurance.

---

## Objectives

- Understand the purpose and applications of data linkage.
- Learn when to use deterministic, fuzzy, and probabilistic linkage methods.
- Evaluate linkage quality using metrics such as **precision**, **recall**, and **F-measure**.
- Apply best practices for data cleaning and record matching.
- Learn how to do deterministic, fuzzy, and probabilistic linkage by R or Stata.

---

## Slides and Materials

- **English Slides**: [Link](https://ucsf.box.com/s/anubn3kle4skfl3jjz94cpfz8icm59xe)
- **Vietnamese Slides**: [Link](https://ucsf.box.com/s/vux84sqjre0ppk1qolvjj83hkqo5e42e)
- **R Syntax**: [Link](R_Syntax_DataLinkage.R)
- **Stata Do file**: [Link](Stata_DoFile_DataLinkage.do)

---

## Recording

- **Recorded Video:** Will be added after the presentation.

---

## Topics Covered

### What is Data Linkage?
Understanding how records from different datasets are connected to identify the same individual or entity.

### Deterministic Linkage
Matching records using **exact identifiers** and predefined rules. Best suited when high-quality, consistent identifiers (e.g., ID numbers, dates of birth) are available.

### Fuzzy Matching
Using **similarity algorithms** to match names, addresses, and other imperfect text fields where spelling variations, typos, or inconsistencies exist.

### Probabilistic Linkage
Estimating the likelihood that records belong to the same person despite discrepancies, and matching records based on a **probability threshold** (Fellegi-Sunter model).

### Practical Tips
Best practices for:
- Data cleaning and standardization
- Match evaluation and threshold selection

---

## Talk Questions

- What is data linkage, and why is it important?
- When should deterministic linkage be used?
- How do fuzzy matching algorithms compare records with imperfect or inconsistent text?
- How does probabilistic linkage estimate whether records belong to the same individual?
- How can linkage quality be evaluated using precision, recall, and F-measure?
- Which tools and software packages are available for data linkage in R and Stata?

---

## Target Audience

This session is intended for:
- Researchers and data analysts
- Epidemiologists and public health professionals
- Data scientists
- Anyone working with **data integration**, **record linkage**, or **population-level datasets**

---

## Prerequisites

No prior experience with data linkage is required. Familiarity with datasets and basic data management concepts is helpful but not necessary.

---

## Contact

For questions or feedback, feel free to open an [issue](https://github.com/amirzazadeh/DataLinkage/issues) or reach out via GitHub.
