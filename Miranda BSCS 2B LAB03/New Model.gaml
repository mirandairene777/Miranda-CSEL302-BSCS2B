model Classroom

global {

    int nb_students <- 25;
    float world_size <- 100.0;

    bool is_break <- false;

    float avg_attention -> { student mean_of each.attention };
    float avg_performance -> { student mean_of each.performance };
    int high_attention_count -> { student count (each.attention > 0.7) };

    init {
        create student number: nb_students {
            location <- {rnd(world_size), rnd(world_size)};
        }
    }

    reflex classroom_cycle {

        if (cycle mod 15 = 0) {
            is_break <- ! is_break;
        }

        save [
            cycle,
            avg_attention,
            avg_performance,
            is_break,
            high_attention_count
        ]
        to: "classroom_data.csv"
        format: "csv"
        rewrite: (cycle = 0) ? true : false
        header: true;
    }
}

species student {

    float attention <- rnd(1.0);
    float performance <- 0.5;
    float mobility <- rnd(1.0);
    int low_attention_streak <- 0;

    rgb color <- #blue;

    reflex update_attention {

        if (is_break) {
            attention <- min(1.0, attention + 0.05);
        } else {
            attention <- max(0.0, attention - 0.05);
        }

        if (attention > 0.8) {
            performance <- min(1.0, performance + 0.01);
        }

        if (attention < 0.3) {
            low_attention_streak <- low_attention_streak + 1;
        } else {
            low_attention_streak <- 0;
        }

        if (low_attention_streak >= 10) {
            performance <- max(0.0, performance - 0.01);
        }

        if (attention > 0.7) {
            color <- #pink;
        } else if (attention > 0.4) {
            color <- #yellow;
        } else {
            color <- #blue;
        }
    }

    reflex move {

        float step_size <- mobility * 2;
        float angle <- rnd(360.0);

        location <- location + {step_size * cos(angle), step_size * sin(angle)};
    }

    aspect base {
        draw circle(2) color: color;
    }
}

experiment classroom_simulation type: gui {

    parameter "Initial number of students:" var: nb_students min: 10 max: 100;

    output {

        display main_display type: 2d {
            species student aspect: base;
        }

        monitor "Average Attention" value: avg_attention;
        monitor "Average Performance" value: avg_performance;
        monitor "High Attention Count" value: high_attention_count;
    }
}