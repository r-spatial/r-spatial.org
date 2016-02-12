---
layout: post
title:  "Reminder"
date:   2016-02-11 11:00:00 +0100
comments: true
categories: r
---
<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

This is to remind myself how to do $$\LaTeX$$ stuff in markdown, found [here](http://gastonsanchez.com/opinion/2014/02/16/Mathjax-with-jekyll/)

Some math: $$S \times T \Rightarrow Q$$

$$\mathsf{Data = PCs} \times \mathsf{Loadings}$$

$$ \mbox{Data = PCs} \times \mbox{Loadings} $$

$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$

{% if post.comments %} 
{% endif %} 
