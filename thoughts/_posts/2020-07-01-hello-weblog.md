---
layout: post
title:  "Hello Weblog and How I Made You"
date:   2020-07-01 19:53:00
---
<div style="text-align:center"><img src="/assets/shawshank.gif" /></div>
<br/>
Welcome to Joe's Ye Olde Fashioned Weblog. This is the first post! Are you ready? In this one I'll lay out how this blog was created to maybe inspire other peeps to host their own too. Or maybe not.

UP TO YOU.

I had three ordered goals when setting out into the great blogknown.
1. Ease. I can be lazy so I wanted the fewest number of barriers between me and writing/publishing content.
2. Thrift. Less than 5 dollars a month was my goal.
3. Ownership. Medium is easy but by posting you grant them rights to [publish your content][medium-agreement].

After I go over each technological choice I made, let's revisit these goals and see how I fared.

## Jekyll
I first considered using react to create a simple static site but I really
didn't want to set up all the css to make it look nice (see goal 1, word 5). After
googling around for a few minutes I found [jekyll][jekyll]. It was created by the founder of github
in 2008 and claims to be a blog-aware static website generator. It unsurprisingly powers github-pages.

What drew me to jekyll was that I could be as hands off or as hands on as I want. Following the docs was
easy enough to get jekyll running locally and after that I just had to choose where to host the static files it generated.

## AWS S3 + Terraform
In the daylight hours I am a devops engineer at a company vendor-locked to AWS. Its where
I cut my teeth on devops. I and a couple others led the infrastructure-as-code revolution
transforming the hodgepodge of bash/python/ansible/cloudformation-on-occasion into one standard
across the various microservices.

After much deliberation we settled on terraform, i.e. my boss chose for us. I hated it
at first because you literally have to use [hacks][hacks] to do anything useful.
But in the end I grew to love it because you feel smart using [hacks][hacks] to do anything useful.

And so I went with what I knew because what's easier? I use AWS resources managed by terraform to host this blog.
The three AWS resources I use are: public S3 bucket, Route53 alias to the bucket, and a hosted zone. I also purchased my domain through AWS.

Here is a link to my [main.tf][terraform-main] which manages the public S3 bucket, Route53 alias, and S3 objects.
It assumes you have an AWS hosted zone configured for a domain you own, and a static website contained within a \_site directory.
If you have that you should be able to plop your hosted zone ID in there, configure the variables to your liking, and run apply.

This resource is where the real magic happens.
{% highlight terraform %}

resource "aws_s3_bucket_object" "static_site" {
  for_each = fileset("${path.module}/thoughts/_site", "**")

  bucket = "${aws_s3_bucket.b.id}"
  key    = each.value
  source = "${path.module}/thoughts/_site/${each.value}"
  content_type = "${length(regexall(".*.css", "${each.value}")) > 0 ? "text/css" : "text/html"}"
  acl = "public-read"
  etag = "${filemd5("thoughts/_site/index.html")}"
}

{% endhighlight %}

It manages all of the static files contained within the S3 bucket and allows me
to simply run `terraform apply` to publish new content. The tricky bit was knowing to use etag with an md5 hash to get terraform to pick up
changes to files and using a regex to denote html from css so that the site doesn't look like a mangled html mess.

Okay let's see how I fared with the goals!

# Ease
My process is now:
1. Write content using the power of markdown and `jekyll serve`'s hot reloading.
2. terraform apply
3. git add -A && git commit -m "sumthn" && git push

So far (Day 0) I am enjoying this process.

All of the configuration and content is kept in a [github repo][repo] so I can easily manage it from any machine.


# Thrift
Here's a screenshot of my bill for June. The extra 8 cents was for a sleeping Terraria server so ignore that.
![billz](/assets/aws_bill.png)
Not pictured is the cost for the domain. I paid $85 for 5 years so some simple math says thats $1.42/month.
So all told I am paying $1.92/month to host my blog. My goal was $5/month so we're good!

# Ownership
Section 8.1 of the [AWS User Agreement][aws-agreement]
> 8.1 Your Content. Except as provided in this Section 8, we obtain no rights under this Agreement from you (or your licensors) to Your Content. You consent to our use of Your Content to provide the Service Offerings to you and any End Users.

This post is all mine.
Thanks AWS and fuck you Medium.
:blush:
<br/>
<br/>

---

<br/>

So what's next? I plan to use this blog to post unadulterated content from my brain. Mostly hoping to use it as a live journal for various interests I have like videogames, books, movies, tech, comics, and random other hobbies I dip my toes into. Thanks for reading. :)

Love,
<br/>
Joe

[jekyll]: https://jekyllrb.com
[medium]: https://www.growthmachine.com/blog/should-you-publish-on-medium#:~:text=The%20biggest%20problem%20with%20making,the%20audience%20you've%20built.&text=No%20matter%20how%20benign%20your%20content%20is.
[hacks]: https://blog.logrocket.com/dirty-terraform-hacks/

[terraform-main]: https://github.com/jmdeon/personal_website/blob/master/main.tf
[repo]: https://github.com/jmdeon/personal_website

[aws-agreement]: https://aws.amazon.com/agreement/
[medium-agreement]: https://policy.medium.com/medium-terms-of-service-9db0094a1e0f#:~:text=Content%20rights%20%26%20responsibilities,reformatting%2C%20and%20distributing%20it).
