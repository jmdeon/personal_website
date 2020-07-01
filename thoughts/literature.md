---
layout: default
title: Literature
---
<h2 class="post-list-heading">Literature</h2>

{% for literature in site.literature reversed %}
  <ul class="post-list"><li><span class="post-meta">{{literature.date | date: "%A %b %d, %Y"}}</span>
      <h3>
        <a class="post-link" href="{{ literature.url }}">
          {{ literature.title }}
        </a>
      </h3></li></ul>
{% endfor %}
