# MLB-Hitting-Classification
This R project explores the classification of MLB hitting data with a K-Nearest Neighbor algorithm.
Launch angles and exit velocities from May 1st to 10th of the 2024 season were used as baseline observations (6,000 in total) for a subset of batted balls from the same timeframe (477 observations).

The chart of exit velocities and launch angles from the training set is shown below:
![Spray Chart](https://github.com/user-attachments/assets/6deaebb6-8070-4613-811f-76f25c5a7dda)

Batted balls were grouped into five primary outcomes: out, single, double, triple, and home run. "Out equivalents," such as errors, fielders choices, sacrifice flies, etc. were also categorized as outs. Unique outcomes, such as a lone catchers interference, were omitted.

477 additional batted balls from the same timeframe were used to test the K-Nearest Neighbor algorithm, with the ultimate goal of finding the ideal value for "K". The chart below shows the accuracy of the KNN algorithm as K changes from 1 to 200.
![KNN Accuracy](https://github.com/user-attachments/assets/5836c877-aef7-45ee-bc32-8a84e3722feb)

After the accuracy sharply increases as K approaches 20, it appears to level out the rest of the way. There is a slight peak in the range of 60 to 80, with the actual highest value (an accuracy of 79.03%) occurring at k = 74.
